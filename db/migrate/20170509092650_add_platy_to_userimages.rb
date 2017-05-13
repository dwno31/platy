class AddPlatyToUserimages < ActiveRecord::Migration[5.0]
  def change
    add_column :userimages, :platy, :string
  end
end
