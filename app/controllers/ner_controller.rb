require 'csv'
require 'axlsx'
# require 'gruff'
class NerController < ApplicationController
  before_action :require_admin, only: [:show_data_training]
  # LOCATION_KEYWORDS = Location.pluck(:lokasi).map(&:downcase)
  def show_data_training

    total = DataItem.count
    limit = (total * 0.3).to_i
    @dataTesting = DataItem.order(created_at: :desc).limit(limit)
    @dataTraining = DataItem.where.not(id: @dataTesting.map(&:id))

    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model

    location_keywords = Location.pluck(:lokasi).map(&:downcase)

    @predicted_training = predict_training_data(svm_service, location_keywords)
    @training_metrics = calculate_metrics_for(@predicted_training)
  end

  def show
    total = DataItem.count
    limit = (total * 0.3).to_i
    @dataTesting = DataItem.order(created_at: :desc).limit(limit)
    @dataTraining = DataItem.where.not(id: @dataTesting.map(&:id))

    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model

    # Pastikan LOCATION_KEYWORDS tersedia, bisa diinisialisasi di sini:
    location_keywords = Location.pluck(:lokasi).map(&:downcase)

    # # Method deteksi lokasi dari clean_caption
    # define_singleton_method(:find_location_from_clean_caption) do |clean_caption|
    # text = clean_caption.downcase
    # sorted_locations = location_keywords.sort_by { |loc| -loc.split.size }

    # sorted_locations.each do |loc|
    #   return loc if text.include?(loc)
    # end
    # nil
    @predicted_data = @dataTesting.map do |value|
    tokens = svm_service.preprocess_text(value.caption)
    clean_caption = tokens.join(" ")   #menggabungkan token menjadi string
    # detected_location = find_location_from_clean_caption(clean_caption)
    location_result = svm_service.detect_location_ner(clean_caption, location_keywords)

    {
      caption: value.caption,
      clean_caption: clean_caption, #sudah dalam string
      label: value.label,
      prediction: svm_service.predict(value.caption),
      location_keywords: location_result[:locations_from_keywords],
      location_pattern: location_result[:location_pattern],
      all_locations: location_result[:all_locations]
      # detected_location: detected_location
    }
    end
    @testing_metrics = calculate_metrics_for(@predicted_data)
    # 💡 Inisialisasi untuk dipakai di view
    @confusion = {
      tp: @testing_metrics[:tp],
      fp: @testing_metrics[:fp],
      tn: @testing_metrics[:tn],
      fn: @testing_metrics[:fn]
    }
    @accuracy  = @testing_metrics[:accuracy]
    @precision = @testing_metrics[:precision]
    @recall    = @testing_metrics[:recall]
    @f1Score   = @testing_metrics[:f1_score]

  end

  def calculate_metrics_for(data_array)
  #Menghitung confussion matrix
    tp = fp = tn = fn = 0

    data_array.each do |data|
      actual = data[:label]         # 1 atau 0
      predicted = data[:prediction] == "Contains Location" ? 1 : 0# "location" atau "no location"

      if actual == 1 && predicted == 1
        tp += 1
      elsif actual == 0 && predicted == 1
        fp += 1
      elsif actual == 0 && predicted == 0
        tn += 1
      elsif actual == 1 && predicted == 0
        fn += 1
      end
    end

    totalAc = tp + tn + fp + fn
    accuracy = totalAc.zero? ? 0 : (tp + tn).to_f / totalAc * 100

    totalPr = tp + fp
    precision = totalPr.zero? ? 0 : tp.to_f / totalPr * 100

    totalRec = tp + fn
    recall = totalRec.zero? ? 0 : tp.to_f / totalRec * 100

    tScore = precision + recall
    f1_score = tScore.zero? ? 0 : 2 * precision * recall / tScore

    {
      tp: tp,
      fp: fp,
      tn: tn,
      fn: fn,
      accuracy: accuracy,
      precision: precision,
      recall: recall,
      f1_score: f1_score
    }
  end

  def train
    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model
    # Simpel, untuk demo simpan model ke instance variable (tidak persistent)
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

  def show_grafik
    total = DataItem.count
    limit = (total * 0.3).to_i
    @dataTesting = DataItem.order(created_at: :desc).limit(limit)
    @dataTraining = DataItem.where.not(id: @dataTesting.map(&:id))

    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model

    location_keywords = Location.pluck(:lokasi).map(&:downcase)

    @predicted_data = @dataTesting.map do |value|
      tokens = svm_service.preprocess_text(value.caption)
      clean_caption = tokens.join(" ")
      location_result = svm_service.detect_location_ner(clean_caption, location_keywords)

      {
        caption: value.caption,
        clean_caption: clean_caption,
        label: value.label,
        prediction: svm_service.predict(value.caption),
        location_keywords: location_result[:locations_from_keywords],
        location_pattern: location_result[:location_pattern],
        all_locations: location_result[:all_locations]
      }
    end
    @testing_metrics = calculate_metrics_for(@predicted_data)

    @confusion = {
      tp: @testing_metrics[:tp],
      fp: @testing_metrics[:fp],
      tn: @testing_metrics[:tn],
      fn: @testing_metrics[:fn]
    }
    @accuracy  = @testing_metrics[:accuracy]
    @precision = @testing_metrics[:precision]
    @recall    = @testing_metrics[:recall]
    @f1Score   = @testing_metrics[:f1_score]

  end

  def visualisasi
    total = DataItem.count
    limit = (total * 0.3).to_i
    @dataTesting = DataItem.order(created_at: :desc).limit(limit)
    @dataTraining = DataItem.where.not(id: @dataTesting.map(&:id))

    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model
    location_keywords = Location.pluck(:lokasi).map(&:downcase)

    @predicted_data = @dataTesting.map do |value|
      tokens = svm_service.preprocess_text(value.caption)
      clean_caption = tokens.join(" ")
      location_result = svm_service.detect_location_ner(clean_caption, location_keywords)

      {
        caption: value.caption,
        length: clean_caption.length,
        label: value.label,
        prediction: svm_service.predict(value.caption),
        location_count: location_result[:all_locations].size
      }
    end
    @summary_data = {
      "Mengandung Lokasi" => @predicted_data.count { |d| d[:prediction] == "Contains Location" },
      "Tidak Mengandung Lokasi" => @predicted_data.count { |d| d[:prediction] == "No Location" }
    }

   @chart_data = [
      {
        name: "Dengan Lokasi",
        data: @predicted_data
          .select { |d| d[:location_count] > 0 }
          .map { |d| [d[:length], d[:location_count]] }
      },
      {
        name: "Tanpa Lokasi",
        data: @predicted_data
          .select { |d| d[:location_count] == 0 }
          .map { |d| [d[:length], d[:location_count]] }
      }
    ]
  end

  def export_predictions_csv
    total = DataItem.count
    limit = (total * 0.3).to_i
    @dataTesting = DataItem.order(created_at: :desc).limit(limit)
    @dataTraining = DataItem.where.not(id: @dataTesting.map(&:id))

    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model

    location_keywords = Location.pluck(:lokasi).map(&:downcase)

    @predicted_data = @dataTesting.map do |value|
      tokens = svm_service.preprocess_text(value.caption)
      clean_caption = tokens.join(" ")
      location_result = svm_service.detect_location_ner(clean_caption, location_keywords)

      {
        caption: value.caption,
        clean_caption: clean_caption,
        label: value.label,
        prediction: svm_service.predict(value.caption),
        location_keywords: location_result[:locations_from_keywords],
        location_pattern: location_result[:location_pattern],
        all_locations: location_result[:all_locations]
      }
    end
    headers = [
      "No", "Caption", "Clean Caption", "Label Sebelum", "Label Prediksi",
      "Location (Keyword)", "Location (Pattern)", "All Detected Locations"
    ]

    csv_data = CSV.generate(headers: true) do |csv|
      csv << headers

      @predicted_data.each_with_index do |item, index|
        csv << [
          index + 1,
          item[:caption],
          item[:clean_caption],
          item[:label],
          item[:prediction],
          Array(item[:location_keywords]).join(" | "),
          Array(item[:location_pattern]).join(" | "),
          Array(item[:all_locations]).join(" | ")
        ]
      end
    end
    send_data csv_data, filename: "hasil_prediksi_svm.csv"
  end

  def export_predictions_excel
    total = DataItem.count
    limit = (total * 0.3).to_i
    @dataTesting = DataItem.order(created_at: :desc).limit(limit)
    @dataTraining = DataItem.where.not(id: @dataTesting.map(&:id))

    svm_service = SvmSentenceClassifierService.new
    svm_service.train_model

    location_keywords = Location.pluck(:lokasi).map(&:downcase)

    @predicted_data = @dataTesting.map do |value|
      tokens = svm_service.preprocess_text(value.caption)
      clean_caption = tokens.join(" ")
      location_result = svm_service.detect_location_ner(clean_caption, location_keywords)

      {
        caption: value.caption,
        clean_caption: clean_caption,
        label: value.label,
        prediction: svm_service.predict(value.caption),
        location_keywords: location_result[:locations_from_keywords],
        location_pattern: location_result[:location_pattern],
        all_locations: location_result[:all_locations]
      }
    end
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "Hasil Prediksi SVM") do |sheet|
      sheet.add_row [
        "No", "Caption", "Clean Caption", "Label Sebelum", "Label Prediksi",
        "Location (Keyword)", "Location (Pattern)", "All Detected Locations"
      ]

      @predicted_data.each_with_index do |item, index|
        sheet.add_row [
          index + 1,
          item[:caption],
          item[:clean_caption],
          item[:label],
          item[:prediction],
          Array(item[:location_keywords]).join(" | "),
          Array(item[:location_pattern]).join(" | "),
          Array(item[:all_locations]).join(" | ")
        ]
      end
    end

    send_data package.to_stream.read,
              filename: "hasil_prediksi_svm.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def predict_training_data(svm_service, location_keywords)
    @dataTraining.map do |value|
      tokens = svm_service.preprocess_text(value.caption)
      clean_caption = tokens.join(" ")
      location_result = svm_service.detect_location_ner(clean_caption, location_keywords)

      {
        caption: value.caption,
        clean_caption: clean_caption,
        label: value.label,
        prediction: svm_service.predict(value.caption),
        location_keywords: location_result[:locations_from_keywords],
        location_pattern: location_result[:location_pattern],
        all_locations: location_result[:all_locations]
      }
    end
  end

end
