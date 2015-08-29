class AddPwzToUser < ActiveRecord::Migration
  def change
    add_column :users, :pwz, :string
  end
end
