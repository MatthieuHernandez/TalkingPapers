class RenameDigestColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :password_digest  , :encrypted_password
    rename_column :users, :remember_digest  , :remember_token
    rename_column :users, :activation_digest, :confirmation_token
    rename_column :users, :activated_at     , :confirmed_at
    rename_column :users, :reset_digest     , :reset_password_token
    rename_column :users, :reset_sent_at    , :reset_password_sent_at
  end
end
