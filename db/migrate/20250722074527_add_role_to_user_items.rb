class AddRoleToUserItems < ActiveRecord::Migration[8.0]
  def change
    add_column :user_items, :role, :string
  end
end
