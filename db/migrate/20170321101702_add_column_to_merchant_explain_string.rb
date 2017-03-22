class AddColumnToMerchantExplainString < ActiveRecord::Migration[5.0]
  def change
	add_column :merchants, :explain, :text
  end
end
