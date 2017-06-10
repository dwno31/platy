class AddColumnToPromotion < ActiveRecord::Migration[5.0]
  def change
    add_column :promotions, :background, :string
  end
end
