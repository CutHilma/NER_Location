require 'rb-libsvm'

class SvmSentenceClassifierService
  
  location_array = Location.pluck(:lokasi)
  LOCATION_KEYWORDS = location_array.map(&:downcase)

  def detect_location_ner(text)
    pattern = /\b(di|ke|dari|pada|ke arah)\s+([A-Z]\w*(?:\s+[A-Z]\w*)*)/
    match = text.match(pattern)
    
    if match
      location = match[2]
      return "Contains Location"
    else
      return "No Location Found"
    end
  end

  def extract_features(sentence)
    words = sentence.split(" ")
    capital_words = words.select { |w| w[0] =~ /[A-Z]/ }
    
    location_result = detect_location_ner(sentence)
    
    keyword_found = if location_result != "No Location Found"
    else
      # fallback cek lokasi dengan LOCATION_KEYWORDS
      # found = words.any? { |w| LOCATION_KEYWORDS.include?(w.downcase) }
      found = LOCATION_KEYWORDS.any? { |loc| sentence.downcase.include?(loc) }
      found ? 1 : 0
    end

    [
      words.size.to_f / 50.0,
      capital_words.size.to_f / 10.0,
      sentence.length.to_f / 200.0,
      keyword_found.to_f
    ]
  end


  def preprocess_text(text)
    text.gsub(/[^a-z\s]/i, '')            # hapus semua karakter kecuali huruf dan spasi
        .squeeze(" ")                     # hapus spasi berlebih
        .strip                            # hapus spasi di awal/akhir
  end

  def train_model
    data = DataItem.all

    features = []
    labels = []

    data.each do |item|
      f = extract_features(item.caption)
      puts "Caption: #{item.caption.inspect}, Label: #{item.label}, Features: #{f.inspect}"
      features << f
      labels << item.label
    end

    problem = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new
    parameter.cache_size = 100
    parameter.eps = 0.001
    parameter.c = 10
    parameter.kernel_type = Libsvm::KernelType::RBF
    parameter.gamma = 0.5  # gamma buat RBF kernel



    examples = features.map { |f| Libsvm::Node.features(f) }
    problem.set_examples(labels, examples)

    @model = Libsvm::Model.train(problem, parameter)
  end

  def predict(sentence)
    return nil unless @model

    features = extract_features(sentence)
    example = Libsvm::Node.features(features)
    prediction = @model.predict(example)

    prediction == 1 ? "Contains Location" : "No Location"
  end

  attr_reader :model
end

