class AddColumnsToProductRatingInteger < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :rating, :integer
  end
end
