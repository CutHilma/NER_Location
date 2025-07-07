class PagesController < ApplicationController
  def login
    if request.post?
      email = params[:email]
      password = params[:password]

      # Contoh login manual
      if email == "admin@example.com" && password == "123456"
        redirect_to dashboard_path  
      else
        flash.now[:alert] = "Email atau password salah"
        render :login
      end
    end
  end

  def dashboard
  end
end
