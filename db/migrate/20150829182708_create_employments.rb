class CreateEmployments < ActiveRecord::Migration
  def change
    create_table :employments do |t|

      t.timestamps null: false
    end
  end
end
