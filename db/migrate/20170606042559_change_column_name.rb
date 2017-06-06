class ChangeColumnName < ActiveRecord::Migration[5.0]
  def change
    rename_column :feedbacks, :type, :request_type
  end
end
