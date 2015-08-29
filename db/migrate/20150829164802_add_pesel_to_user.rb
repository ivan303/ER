class AddPeselToUser < ActiveRecord::Migration
  def change
    add_column :users, :pesel, :string
  end
end
