require 'rb-libsvm'

class SvmSentenceClassifierService
  LOCATION_KEYWORDS = %w[Aceh Kepulauan Riau Jambi Sumatera Selatan Bangka Belitung Bengkulu Lampung Jawa Barat Banten Jawa Tengah Yogyakarta Nusa Tenggara Barat Nusa Tenggara Timur Kalimantan Barat Kalimantan Tengah Kalimantan Selatan Sulawesi Utara Gorontalo Sulawesi Tengah Sulawesi Barat Sulawesi Selatan Sulawesi Tenggara Maluku Maluku Utara Papua Papua Barat Papua Tengah Papua Pegunungan Papua Selatan Papua Barat Daya Kalimantan Timur Kalimantan Utara Jawa Timur Jakarta Bandung Surabaya Medan Bali Riau Sumatera Utara]

  def extract_features(sentence)
    words = sentence.split(" ")
    capital_words = words.select { |w| w[0] =~ /[A-Z]/ }
    keyword_found = words.any? { |w| LOCATION_KEYWORDS.include?(w) } ? 1 : 0
  
    [
      words.size.to_f / 50.0,           # asumsi max 50 kata
      capital_words.size.to_f / 10.0,   # asumsi max 10 kata kapital
      sentence.length.to_f / 200.0,     # asumsi max panjang 200 karakter
      keyword_found.to_f
    ]
  end  

  def preprocess_text(text)
    text.downcase                         # konversi ke huruf kecil
        .gsub(/[^a-z\s]/i, '')            # hapus semua karakter kecuali huruf dan spasi
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

