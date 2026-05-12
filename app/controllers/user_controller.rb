class UserController < ApplicationController

    before_action :require_admin, only: [:show, :addData, :create, :editData, :edit, :delete]

    def show
        if current_user.nil?
            redirect_to login_path, alert: "Silakan login dulu."
        elsif current_user.role != "admin"
            redirect_to dashboard_path, alert: "Kamu tidak punya akses ke sini."
        else
            @userItem = UserItem.all
            @user_item = UserItem.count
        end
    end

    def addData
    end

    def create
        @user_item = UserItem.new(
        username: params[:username],
        password: params[:password],
        role: params[:role] || "user" # default ke "user"
        )
        @user_item.save
        flash[:pesan] = "<div class='alert alert-success alert-dismissible fade show' data-bs-dismiss='alert' aria-label='Close'>User berhasil ditambahkan.</div>"
        redirect_to("/user/show")
    end

    def editData
        @user_item = UserItem.find(params[:id])
    end

    def edit
        @user_item = UserItem.find(params[:id])
        @user_item.username = params[:username]
        @user_item.password = params[:password]
        @user_item.save
        flash[:pesan] = "<div class='alert alert-success alert-dismissible fade show' data-bs-dismiss='alert' aria-label='Close'>User berhasil diubah.</div>"
        redirect_to("/user/show")
    end

    def delete
        @user_item = UserItem.find(params[:id])
        @user_item.destroy
        flash[:pesan] = "<div class='alert alert-success alert-dismissible fade show' data-bs-dismiss='alert' aria-label='Close'>Data berhasil dihapus.</div>"
        redirect_to("/user/show")
    end

    # Profil pengguna biasa
    def profile
        @user_item = current_user
    end

    def update_profile
        @user_item = current_user
        if @user_item.update(username: params[:username], password: params[:password])
            flash[:pesan] = "Profil berhasil diperbarui."
        else
            flash[:pesan] = "Gagal memperbarui profil."
        end
        redirect_to profile_path
    end

    private

    def require_admin
        unless current_user&.role == "admin"
            flash[:alert] = "Akses ditolak. Anda bukan admin."
            redirect_to root_path
        end
    end


end
