class AddOmniauthToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :provider, :string
    add_column :users, :external_id, :string
    add_column :users, :picture_link, :string
  end
end

