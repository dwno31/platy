class AddColumnToUserPreferStringReally < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :prefer, :string
  end
end
