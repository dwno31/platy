class AddColumnsToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :title, :string
    add_column :products, :price, :integer
    add_column :products, :hashtag, :text
    add_column :products, :category, :string
    add_column :products, :status, :string
  end
end
