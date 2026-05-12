require'csv'
class DataController < ApplicationController
  before_action :require_login, except: [:show]
  before_action :check_admin, only: [ :addData , :edit, :delete, :editData, :create]

  def show
    @data_items = DataItem.order(created_at: :desc)
    @dataItem = DataItem.all
    @data_item = DataItem.count

    # Statistik panjang caption
    captions = DataItem.pluck(:caption).compact  # hindari nil
    lengths = captions.map(&:length)

    if lengths.present?
      @min_length = lengths.min
      @max_length = lengths.max
      @avg_length = (lengths.sum.to_f / lengths.size).round
    else
      @min_length = 0
      @max_length = 0
      @avg_length = 0
    end

    @total_caption = DataItem.count
    @jumlah_label_1 = DataItem.where(label: 1).count
    @jumlah_label_0 = @total_caption - @jumlah_label_1

    statistik_caption
  end

  def addData
  end

  def create
    @data_item = DataItem.new(caption: params[:caption], label: params[:label])
    @data_item.save
    flash[:pesan] = "<div class='alert alert-success alert-dismissible fade show' data-bs-dismiss='alert' aria-label='Close'>Data berhasil ditambahkan.</div>"
    redirect_to("/data/show")
  end

  def editData
    @data_item = DataItem.find(params[:id])
  end

  def edit
    @data_item = DataItem.find(params[:id])
    @data_item.caption = params[:caption]
    @data_item.label = params[:label]
    @data_item.save
    flash[:pesan] = "<div class='alert alert-success alert-dismissible fade show' data-bs-dismiss='alert' aria-label='Close'>Data berhasil diubah.</div>"
    redirect_to("/data/show")
  end

  def delete
    @data_item = DataItem.find(params[:id])
    @data_item.destroy
    flash[:pesan] = "<div class='alert alert-success alert-dismissible fade show' data-bs-dismiss='alert' aria-label='Close'>Data berhasil dihapus.</div>"
    redirect_to("/data/show")
  end

  def export_csv
    @data = DataItem.all

    csv_string = CSV.generate(headers: true) do |csv|
      csv << ["ID", "Caption", "Label"]
      @data.each do |item|
        csv << [item.id, item.caption, item.label]
      end
    end
    send_data csv_string, filename: "data_caption_#{Time.now.strftime("%Y%m%d")}.csv", type: :csv
  end

  def statistik_caption
    @total_caption = DataItem.count

    captions = DataItem.pluck(:caption).compact
    lengths = captions.map(&:length)
    @min_length = lengths.min
    @max_length = lengths.max
    @avg_length = (lengths.sum.to_f / lengths.size).round

    @jumlah_label_1 = DataItem.where(label: 1).count
    @jumlah_label_0 = DataItem.where(label: 0).count

    @chart_data = {
      "Mengandung Lokasi" => @jumlah_label_1,
      "Tidak Mengandung Lokasi" => @jumlah_label_0
    }
  end
end
