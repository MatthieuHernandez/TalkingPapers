class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.string :url
      t.text :title
      t.string :download_link

      t.timestamps
    end
  end
end
