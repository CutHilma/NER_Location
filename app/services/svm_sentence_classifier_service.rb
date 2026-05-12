require 'rb-libsvm'


class SvmSentenceClassifierService
  def initialize
    @location_keywords = Location.pluck(:lokasi).map(&:strip)
  end

  def detect_location_ner(text, location_keywords)
    clean_caption = preprocess_text(text).join(" ")
    found_location = []

    normalize_text = clean_caption.downcase
    normalize_keywords = location_keywords.map(&:downcase)

    # 1. Exact match dari keyword lokasi
    normalize_keywords.each_with_index do |loc, idx|
      escape = Regexp.escape(loc)
      if normalize_text.match?(/\b#{escape}\b/)
        found_location << location_keywords[idx]
      end
    end

    # 2. Berdasarkan pola preposisi + kapital
    exception_words = %w[
      WhatsApp Instagram Facebook Twitter YouTube TikTok WA WAchannel
      Google Gmail Shopee Tokopedia Telegram Line Discord
      Website Channel Link Bio Linktree
      Antara Kompas CNN Detik Tribun Liputan6 CNBC Viva Kumparan IDN Times
    ]

    context_stopwords = %w[
      namun tetapi dan atau sehingga meskipun walaupun karena
      jika yang dengan oleh untuk dalam masih sudah belum
      betul sedang supaya maka dalam sebagai Checkk
    ]

    prepositions = [
      'di', 'ke', 'dari', 'menuju', 'mendaki',
      'ke arah', 'perjalanan ke', 'liburan di',
      'trip ke', 'di perairan', 'di area', 'Di', 'Dari'
    ]

    pattern_preposition = /\b(#{prepositions.join('|')})\s+([A-Z][\w-]*(?:\s+[A-Z][\w-]*){0,2})/
    pattern_locations = []

    clean_caption.scan(pattern_preposition) do |prep, candidate|
      full_match = "#{$~[0]}"
      start_index = $~.begin(0) + full_match.length
      after_string = clean_caption[start_index..].to_s.strip
      next_word = after_string.split.first&.downcase

      words = candidate.strip.split

      next if exception_words.any? { |ex| candidate.include?(ex) }
      next if words.any? { |word| context_stopwords.include?(word.downcase) }
      next if next_word && context_stopwords.include?(next_word)
      next if words.length < 1

      pattern_locations << candidate.strip
    end

    # 3. Berdasarkan struktur nama lokasi (eksplisit + soft)
    deskriptor = [
      "Kota", "Kabupaten", "Provinsi", "Kecamatan", "Desa",
      "Kelurahan", "Jalan", "Jl.", "Gunung", "Danau",
      "Laut", "Teluk", "Pulau", "Bandar Udara", "Bandara",
      "Taman Mini", "Pasar", "Gedung", "Stasiun","Universitas",
      "Museum", "Dermaga", "Pelabuhan", "Terminal", "Kawasan",
      "Bukit", "Stadion", 'Laguna', "Dusun", "Bendungan", "Jln.",
      "Istana", "Keraton", "Gerbang", "Air Terjun", "Pantai", "Kawah"
    ]

    structure_matches = []
    possible_soft_matches = []

    deskriptor.each do |desc|
      # Kapital pattern
      pattern = /\b#{desc}\s((?:[A-Z][\w-]*\s?){1,5})/
      clean_caption.scan(pattern).each do |match|
        structure_matches << "#{desc} #{match[0].strip}"
      end


     # Soft pattern (huruf kecil, aman)
      pattern_soft = /\b#{desc.downcase}\s((?:[a-z][\w-]*\s?){1,2})/
      normalize_text.scan(pattern_soft).each do |match|
        phrase = "#{desc.downcase} #{match[0].strip}"
        words = match[0].strip.split

        # Filter aman:
        next if words.any? { |w| context_stopwords.include?(w.downcase) || w.length < 3 }

        # Cek kata setelahnya
        after_index = normalize_text.index(phrase) + phrase.length rescue nil
        after_token = normalize_text[after_index..].to_s.strip.split.first
        next if after_token && context_stopwords.include?(after_token.downcase)


        unless structure_matches.map(&:downcase).include?(phrase.downcase)
          possible_soft_matches << phrase
        end
      end
    end

    # Gabungkan semua
    all_found = (found_location + pattern_locations + structure_matches+possible_soft_matches).uniq
    location_pattern = (pattern_locations + structure_matches+possible_soft_matches).uniq

    {
      text: text,
      locations_from_keywords: found_location.uniq,
      locations_from_pattern: pattern_locations.uniq,
      locations_from_structure: structure_matches.uniq,
      possible_location: possible_soft_matches.uniq,
      location_pattern: location_pattern,
      all_locations: all_found
    }
  end


  def extract_features(sentence, location_keywords)
    clean_sentence = preprocess_text(sentence).join(" ")

    words = clean_sentence.split(" ")
    capital_words = words.select { |w| w[0] =~ /[A-Z]/ }

    location_result = detect_location_ner(clean_sentence, location_keywords)

    keyword_found = location_result[:all_locations].any? ? 1 : 0

    [
      words.size.to_f / 50.0,
      capital_words.size.to_f / 10.0,
      clean_sentence.length.to_f / 200.0,
      keyword_found.to_f
    ]
  end


  def preprocess_text(text)

    text = text.gsub(/#[\w-]+/, '')         #menghapus hastag

    stopwords = %w[ dan yang dengan untuk karena oleh dalam
                    sebagai ini itu kepada terhadap tetapi
                    namun menjadi tag
                    antara maka jika saat sehingga tanpa telah
                    sudah belum bisa tidak iya mengapa bagaimana tiba
                    kemudian merupakan ketika anda kamu aku dia mereka
                  ]
    words = text.gsub(/[^a-z0-9\s.]/i, '')         # hapus semua karakter kecuali huruf, angka, spasi dan titik
                .squeeze(" ")                     # hapus spasi berlebih
                .strip                            # hapus spasi di awal/akhir
                .split(" ")                       # tokenisasi, memecah jadi array kata
                # .reject {|word| stopwords.include?(word)}   #hapus stopwords
    result = []
    i = 0

    while i < words.size
      word = words[i]

      # Deteksi awalan huruf kapital (mungkin entitas)
      if word =~ /^[A-Z]/ && !stopwords.include?(word.downcase)
      # Gabungkan beberapa kata kapital berturut-turut (maks 3 kata)
        entity = [word]
        j = i + 1

        while j < words.size &&
          words[j] =~ /^[A-Z]/ &&
          !stopwords.include?(words[j].downcase) &&
          entity.size < 3
          entity << words[j]
          j += 1
        end

        result << entity.join(" ")
        i = j
      else
        # Hapus stopword
        cleaned_word = word.strip
        unless stopwords.include?(cleaned_word.downcase)
          result << cleaned_word
        end
        i += 1
      end
    end
    result
  end

  def train_model
    data = DataItem.all

    features = []
    labels = []

    data.each do |item|
      token = preprocess_text(item.caption)
      clean_caption = token.join(" ")
      f = extract_features(clean_caption, @location_keywords)
      puts "Caption: #{item.caption.inspect}, Label: #{item.label}, Features: #{f.inspect}"
      features << f
      labels << item.label
    end

    problem = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new

    parameter.cache_size = 100
    parameter.eps = 0.001
    parameter.c = 1
    parameter.kernel_type = Libsvm::KernelType::RBF
    parameter.gamma = 0.5
    examples = features.map { |f| Libsvm::Node.features(f) }
    problem.set_examples(labels, examples)

    @model = Libsvm::Model.train(problem, parameter)
    puts "Model dilatih ulang dengan C = #{parameter.c}, gamma = #{parameter.gamma}"

  end

  def predict(sentence)
    return nil unless @model

    token = preprocess_text(sentence)
    clean_sentence = token.join(" ")
    features = extract_features(clean_sentence, @location_keywords)
    example = Libsvm::Node.features(features)
    prediction = @model.predict(example)

    prediction == 1 ? "Contains Location" : "No Location"
  end

  # def extract_model_info
  #   YAML.load_file(Rails.root.join("svm_model_info.yml")) if File.exist?(Rails.root.join("svm_model_info.yml"))
  # end

  # def load_model
  #   model_path = Rails.root.join("svm_model.dat")
  #   info_path = Rails.root.join("svm_model_info.yml")
  #   return false unless File.exist?(model_path) && File.exist?(info_path)

  #   @model = Libsvm::Model.load(model_path.to_s)
  #   model_info = YAML.load_file(info_path)
  #   @parameter = Libsvm::SvmParameter.new
  #   @parameter.gamma = model_info[:gamma]

  #   @training_features = model_info[:support_vectors]
  #   @training_labels = model_info[:labels]

  #   true
  # end

    # Getter untuk akses luar

  attr_reader :model, :training_features, :training_labels
end
