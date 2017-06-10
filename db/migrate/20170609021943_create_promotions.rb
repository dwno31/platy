class CreatePromotions < ActiveRecord::Migration[5.0]
  def change
    create_table :promotions do |t|
      t.string :title
      t.string :position
      t.text :banner_url
      t.text :header_url

      t.timestamps
    end
  end
end
