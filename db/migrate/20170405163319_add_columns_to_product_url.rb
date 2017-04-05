class AddColumnsToProductUrl < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :url, :text
    add_column :products, :img_url, :text
  end
end
