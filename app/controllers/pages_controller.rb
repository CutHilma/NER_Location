class PagesController < ApplicationController
  def login
    if request.post?
      username = params[:username]
      password = params[:password]

      user = UserItem.find_by(username: username, password: password)

      if user
        redirect_to dashboard_path  # Ganti sesuai route tujuan
      else
        flash.now[:alert] = "Username atau password salah"
        render :login
      end
    end
  end
end
