class CreateProductswithpromotions < ActiveRecord::Migration[5.0]
  def change
    create_table :productswithpromotions do |t|
      t.references :product, foreign_key: true
      t.references :promotion, foreign_key: true
      t.string :tag_type
      t.integer :discount

      t.timestamps
    end
  end
end
