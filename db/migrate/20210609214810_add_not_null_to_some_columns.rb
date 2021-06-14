class AddNotNullToSomeColumns < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:articles, :url,             false, "")
    change_column_null(:articles, :title,           false, "")
    change_column_null(:articles, :download_link,   false, "")

    change_column_null(:comments, :note_id,         false, -1)
    change_column_null(:comments, :comment_text,    false, "")
    change_column_null(:comments, :is_anon,         false, false)

    change_column_null(:notes,    :article_id,      false, -1)
    change_column_null(:notes,    :note_text,       false, "")
    change_column_null(:notes,    :note_type,       false, "")
    change_column_null(:notes,    :is_public,       false, true)
    change_column_null(:notes,    :is_anon,         false, false)

    change_column_null(:users,    :name,            false, "")
    change_column_null(:users,    :email,           false, "")
    change_column_null(:users,    :password_digest, false, "")
    change_column_null(:users,    :admin,           false, false)
    change_column_null(:users,    :activated,       false, false)
  end
end
