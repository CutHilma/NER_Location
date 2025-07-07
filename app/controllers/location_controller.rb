class LocationController < ApplicationController
  
  def index
    @lokasi = Location.all
  end

  def addData
  end

  def create
    @lokasi = Location.new(lokasi: params[:lokasi])
    @lokasi.save
    flash[:pesan] = "<div class='alert alert-success alert-dismissible fade show' data-bs-dismiss='alert' aria-label='Close'>Lokasi berhasil ditambahkan.</div>"
    redirect_to("/location/index")
  end

  def editData
    @lokasi = Location.find(params[:id])
  end

  def edit
    @lokasi = Location.find(params[:id])
    @lokasi.lokasi = params[:lokasi]
    @lokasi.save
    flash[:pesan] = "<div class='alert alert-success alert-dismissible fade show' data-bs-dismiss='alert' aria-label='Close'>Data berhasil diubah.</div>"
    redirect_to("/location/index")
  end

  def delete
    @lokasi = Location.find(params[:id])
    @lokasi.destroy
    flash[:pesan] = "<div class='alert alert-success alert-dismissible fade show' data-bs-dismiss='alert' aria-label='Close'>Data berhasil dihapus.</div>"
    redirect_to("/location/index")
  end
end
