class AddColumnsToUserlikes < ActiveRecord::Migration[5.0]
  def change
    add_column :userlikeitems, :active, :boolean, :default => false
    add_column :userlikeshops, :active, :boolean, :default => false
  end
end
