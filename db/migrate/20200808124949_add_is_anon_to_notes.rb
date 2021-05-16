class AddIsAnonToNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :notes, :is_anon, :boolean
  end
end
