class AddColumnToMerchant < ActiveRecord::Migration[5.0]
  def change
	add_column :merchants, :rating, :integer
  end
end
