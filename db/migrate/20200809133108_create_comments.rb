class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.integer :note_id
      t.text :comment_text
      t.integer :user_id
      t.string :username

      t.timestamps
    end
  end
end
