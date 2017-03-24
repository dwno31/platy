class AddColumnToMerchantPrior < ActiveRecord::Migration[5.0]
  def change
	add_column :merchants,:priority,:integer
  end
end
