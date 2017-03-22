class AddColumnsToMerchants < ActiveRecord::Migration[5.0]
  def change
	add_column :merchants, :title, :string
	add_column :merchants, :url, :text
	add_column :merchants, :thumbnail, :text
	add_column :merchants, :story, :text
	add_column :merchants, :hashtag, :text
	add_column :merchants, :category, :string
  end
end
