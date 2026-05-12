class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_login
  helper_method :current_user, :admin?

  def current_user
    @current_user ||= UserItem.find_by(id: session[:user_id])
  end

  def require_login
    allowed_paths = [
      '/login',
      '/logout',
      '/',
      '/instagram_scraper',
      '/instagram_scraper/scrape',
      '/dashboard'
    ]

    # izinkan halaman tanpa login
    if allowed_paths.include?(request.path)
      return
    end

    unless current_user
      redirect_to login_path, alert: "Kamu harus login dulu."
    end
  end

  def admin?
    current_user&.role == "admin"
  end

  def check_admin
    unless current_user&.role == "admin"
      flash[:alert] = "Akses ditolak. Anda bukan admin."
      redirect_to dashboard_path
    end
  end

  def require_admin
    unless admin?
      flash[:alert] = "Akses ditolak. Anda bukan admin."
      redirect_back fallback_location: dashboard_path
    end
  end
end
