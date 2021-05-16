class AddUsernameToNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :notes, :username, :string
  end
end
