class AddIsAnonToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :is_anon, :boolean
  end
end
