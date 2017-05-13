class CreateUserimages < ActiveRecord::Migration[5.0]
  def change
    create_table :userimages do |t|
      t.integer :user_id, index: true
      t.text :hashtag
      t.string :category

      t.timestamps
    end
  end
end
