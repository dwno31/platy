class ChangeColumnNameInMerchant < ActiveRecord::Migration[5.0]
  def change
	rename_column :merchants, :priority, :ranknumber
  end
end
