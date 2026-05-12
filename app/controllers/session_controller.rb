class SessionController < ApplicationController
  skip_before_action :require_login  # supaya bisa buka halaman login tanpa login dulu
  layout 'login', only: [:login]
  def login
    # hanya menampilkan form login
  end

  def do_login
    user = UserItem.find_by(username: params[:username], password: params[:password])
    if user
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Login berhasil"
    else
      flash[:error] = "Username atau password salah"
      render :login
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path, notice: "Logout berhasil"
  end
end
