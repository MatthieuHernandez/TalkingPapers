class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.integer :article_id
      t.integer :page_num
      t.text :note_text
      t.string :note_type
      t.integer :user_id
      t.boolean :is_public

      t.timestamps
    end
  end
end
