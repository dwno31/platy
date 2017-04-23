class CreateUserlikeshops < ActiveRecord::Migration[5.0]
  def change
    create_table :userlikeshops do |t|
      t.references :user, foreign_key: true
      t.references :merchant, foreign_key: true
      t.timestamps
    end
  end
end
