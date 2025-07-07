class CreateDataItems < ActiveRecord::Migration[8.0]
  def change
    create_table :data_items do |t|
      t.string :caption
      t.integer :label

      t.timestamps
    end
  end
end
