class DataController < ApplicationController

  def show
    @dataItem = DataItem.all
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

end
