class UserController < ApplicationController

    def show
        @userItem = UserItem.all
    end

    
    def addData
    end

    def create
        @user_item = UserItem.new(username: params[:username], password: params[:password])
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



end
  