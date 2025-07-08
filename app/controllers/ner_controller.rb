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
    
    tp = fp = tn = fn = 0

    @predicted_data.each do |data|
      actual = data[:label]         # 1 atau 0
      predicted = data[:prediction] # "location" atau "no location"

      if actual == 1 && predicted == "Contains Location"
        tp += 1
      elsif actual == 0 && predicted == "Contains Location"
        fp += 1
      elsif actual == 0 && predicted == "No Location"
        tn += 1
      elsif actual == 1 && predicted == "No Location"
        fn += 1
      end
    end

    @confusion = { tp: tp, fp: fp, tn: tn, fn: fn }

    totalAc = @confusion[:tp] + @confusion[:tn] + @confusion[:fp] + @confusion[:fn]

    correctAc = @confusion[:tp] + @confusion[:tn]
    return 0 if totalAc == 0
    @accuracy = (correctAc.to_f / totalAc) *100

    totalPr = @confusion[:tp] + @confusion[:fp]
    correctPr = @confusion[:tp]
    return 0 if totalPr == 0
    @precision = (correctPr.to_f / totalPr) *100

    totalRec = @confusion[:tp] + @confusion[:fn]
    correctRec = @confusion[:tp]
    return 0 if totalRec == 0
    @recall = (correctRec.to_f / totalRec) *100

    p = @precision
    r = @recall
    tScore = p + r
    return 0 if tScore == 0

    @f1Score = (2 * p * r / tScore)
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
