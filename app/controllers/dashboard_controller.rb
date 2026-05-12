class DashboardController < ApplicationController
  skip_before_action :require_login
  def show
    # @user_item = UserItem.count
    # @data_item = DataItem.count
  end
end
