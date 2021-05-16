class AddParentNoteIdToNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :notes, :parent_note_id, :integer
  end
end
