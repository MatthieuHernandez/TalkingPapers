class AddDefaultValuesToNotNullColumns < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:comments, :is_anon, false)

    change_column_null(:notes,    :is_public,  true)
    change_column_null(:notes,    :is_anon,    false)

    change_column_null(:users,    :admin,      false)
    change_column_null(:users,    :activated,  false)
  end
end
