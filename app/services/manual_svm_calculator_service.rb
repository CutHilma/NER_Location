# class ManualSvmCalculatorService
#   def initialize(svm_service)
#     @svm_service = svm_service
#     @model_info = @svm_service.extract_model_info
#     if @model_info.nil?
#       raise "Model belum dilatih. Jalankan 'train_model' terlebih dahulu sebelum memulai kalkulasi"
#     end

#     @location_keywords = Location.pluck(:lokasi).map(&:downcase)
#   end

#   def calculate_for_data_items(data_items)
#     return [] unless @model_info

#     data_items.map do |item|
#       features = @svm_service.send(:extract_features, item.caption, @location_keywords)

#       kernel_details = @model_info[:support_vectors].each_with_index.map do |sv, i|
#         k_value = rbf_kernel(sv, features, @model_info[:gamma])
#         {
#           sv: sv,
#           alpha: @model_info[:alphas][i],
#           label: @model_info[:labels][i],
#           kernel_value: k_value
#         }
#       end

#       fx = decision_function(kernel_details, @model_info[:bias])
#       hasil = fx > 0 ? "Contains Location" : "No Location"

#       {
#         caption: item.caption,
#         features: features,
#         decision: fx.round(5),
#         prediksi: hasil,
#         kernel_details: kernel_details.map { |k| k.merge(score: (k[:alpha] * k[:label] * k[:kernel_value]).round(5)) },
#         kernel_sum: kernel_details.sum { |k| k[:alpha] * k[:label] * k[:kernel_value] }.round(5),
#         bias: @model_info[:bias].round(5)
#       }
#     end
#   end

#   private

#   def rbf_kernel(x1, x2, gamma)
#     raise "Mismatch fitur: #{x1.size} vs #{x2.size}" unless x1.size == x2.size
#     distance_squared = x1.zip(x2).map { |a, b| (a - b) ** 2 }.sum
#     Math.exp(-gamma * distance_squared)
#   end

#   def normalize_label(label)
#     # Ubah label 0 → -1, label 1 → +1 (jika belum disimpan sebagai -1/1)
#     label.to_i == 0 ? -1.0 : 1.0
#   end

#   def decision_function(kernel_details, bias)
#     sum = kernel_details.sum do |k|
#       k[:alpha] * k[:label] * k[:kernel_value]
#     end
#     fx = sum + bias
#     puts "[DECISION] ∑(α * y * K) = #{sum.round(4)}, bias = #{bias.round(4)}, fx = #{fx.round(4)}"
#     fx
#   end
# end
