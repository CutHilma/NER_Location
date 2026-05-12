class PagesController < ApplicationController
  skip_before_action :require_login
  # def login
  #   if request.post?
  #     username = params[:username]
  #     password = params[:password]

  #     user = UserItem.find_by(username: username, password: password)

  #     if user
  #       redirect_to dashboard_path  # Ganti sesuai route tujuan
  #     else
  #       flash.now[:alert] = "Username atau password salah"
  #       render :login
  #     end
  #   end
  # end

  # def logout
  #   session[:user_id] = nil
  #   redirect_to login_path, notice: "Anda telah logout."
  # end
end
