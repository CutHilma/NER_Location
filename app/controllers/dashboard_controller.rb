class DashboardController < ApplicationController

  def show
    @user_item = UserItem.count
    @data_item = DataItem.count
  end
end
