class AddDefaultValuesToNotNullColumns < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:comments, :is_anon,   to: false, from: nil)

    change_column_default(:notes,    :is_public, to: true, from: nil)
    change_column_default(:notes,    :is_anon,   to: false, from: nil)

    change_column_default(:users,    :admin,     to: false, from: nil)
    change_column_default(:users,    :activated, to: false, from: nil)
  end
end
