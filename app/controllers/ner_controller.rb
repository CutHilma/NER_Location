class NerController < ApplicationController
  def show
    total = DataItem.count
    limit = (total * 0.2).to_i
    @dataTesting = DataItem.order(created_at: :desc).limit(limit)

    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model

    # Tambahkan hasil prediksi ke tiap item (bisa sebagai hash array)
    @predicted_data = @dataTesting.map do |value|
    clean_caption = svm_service.preprocess_text(value.caption)
      {
        caption: value.caption,    # akses atribut model via method, bukan hash string
        clean_caption: clean_caption,
        label: value.label,
        prediction: svm_service.predict(value.caption)
      }
    end 
  end

  def train
    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model
    # Simpel saja, untuk demo simpan model ke instance variable (tidak persistent)
    session[:svm_model] = svm_service.model
    render plain: "Model trained with #{DataItem.count} sentences"
  end

  def predict
    sentence = params[:sentence]
    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model  # untuk demo train dulu tiap request (bisa dioptimalkan)

    result = svm_service.predict(sentence)
    render plain: "#{sentence} => #{result}"
  end
end
