class InstagramScraperController < ApplicationController
  require 'httparty'
  require 'nokogiri'
  require 'csv'

  skip_before_action :require_login
  # def initialize
  #   @location_keywords = Location.pluck(:lokasi).map(&:strip)
  # end
  def index
  end

  def scrape
    url = params[:url]

    begin
      response = HTTParty.get(url, headers: {
        "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
      })
      parsed_page = Nokogiri::HTML(response.body)

      meta_tag = parsed_page.css('meta[property="og:description"]').first
      @caption = meta_tag['content'] if meta_tag
      if @caption.present?
        location_keywords = load_location_keywords
        ner_result = InstagramScraperController.detect_location_ner(@caption, location_keywords)

        @has_location = ner_result[:all_locations].any?
        @ner_entities = ner_result[:all_locations]
        @ner_detail = ner_result

        # Debug log (optional)
        puts "Caption: #{@caption}"
        puts "NER result: #{ner_result.inspect}"
      end
    rescue => e
      @error = "Terjadi kesalahan: #{e.message}"
    end

    render :index

    # Simpan ke tabel data_items
    DataItem.create(
      caption: @caption,
      label: @has_location ? 1 : 0 # 1 jika mengandung lokasi, 0 jika tidak
    )
  end
  def load_location_keywords
    Location.pluck(:lokasi)
  end

  def self.detect_location_ner(text, location_keywords)
    raw_text = text.dup
    clean_caption = self.preprocess_text(text).join(" ")

    found_location = []

    normalize_text = clean_caption.downcase
    normalize_keywords = location_keywords.map(&:downcase)

    # 1. Exact match dari keyword lokasi
    normalize_keywords.each_with_index do |loc, idx|
      escape = Regexp.escape(loc)
      if normalize_text.match?(/\b#{escape}\b/) || raw_text.downcase.match?(/\b#{Regexp.escape(loc)}\b/)
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
      'ke arah', 'perjalanan ke', 'liburan di', 'di wilayah',
      'trip ke', 'di perairan', 'di area', 'Di', 'Dari'
    ]

    pattern_preposition = /\b(#{prepositions.join('|')})\s+([A-Z][\w-]*(?:\s+[A-Z][\w-]*){0,4})/
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
    deskriptor = %w[
      Kota Kabupaten Provinsi Kecamatan Desa Kelurahan Jalan Jl. Gunung Sungai Danau
      Laut Teluk Pulau Bandar Udara Taman Mini Taman Pasar Gedung Stasiun
      Museum Dermaga Pelabuhan Terminal Kawasan Bukit Stadion Laguna
      Dusun Bendungan Jln. Istana Keraton Gerbang Air Terjun Pantai Kawah
      Gampong Jln Jl
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
      location_possible: possible_soft_matches.uniq,
      location_pattern: location_pattern,
      all_locations: all_found
    }
  end

  def self.preprocess_text(text)

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
          entity.size < 4
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


end
