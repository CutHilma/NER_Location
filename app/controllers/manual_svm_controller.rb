class ManualSvmController < ApplicationController

end
  # require 'csv'
# class ManualSvmController < ApplicationController
#   def show
#     svm_service = SvmSentenceClassifierService.new
#     unless svm_service.load_model
#       return render plain: "Model belum tersedia. Silakan latih model terlebih dahulu."
#     end
#     calculator = ManualSvmCalculatorService.new(svm_service)
#     data_training = DataItem.order(created_at: :asc).limit (50)
#     data_testing = DataItem.order(created_at: :desc).limit(30)

#     @training_result = calculator.calculate_for_data_items(data_training)

#     @testing_result = calculator.calculate_for_data_items(data_testing)

#     respond_to do |format|
#       format.html
#       format.xlsx {
#         response.headers['Content-Disposition'] = 'attachment; filename="manual_svm.xlsx"'
#       }
#       format.csv {
#         send_data to_csv(@manual_result),
#                   filename: "manual_svm.csv",
#                   type: 'text/csv'
#       }
#     end
#   end

#   def train
#     svm_service = SvmSentenceClassifierService.new
#     svm_service.train_model

#     redirect_to manual_svm_path, notice: "Model berhasil dilatih."
#   end

#   private

#   def to_csv(data)
#     CSV.generate(headers: true) do |csv|
#       csv << ["Caption", "Features", "Decision Value", "Prediksi", "Bias"]
#       data.each do |item|
#         csv << [
#           item[:caption],
#           item[:features].map { |f| f.round(3) }.join(", "),
#           item[:decision],
#           item[:prediksi],
#           item[:bias]
#         ]
#       end
#     end
#   end
# end
