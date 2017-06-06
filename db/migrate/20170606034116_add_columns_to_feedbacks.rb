class AddColumnsToFeedbacks < ActiveRecord::Migration[5.0]
  def change
    add_reference :feedbacks, :user
    add_column :feedbacks, :location, :string
    add_column :feedbacks, :status, :string
    add_column :feedbacks, :type, :string
    add_column :feedbacks, :message, :text
  end
end
