class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :clinic_id
      t.integer :doctor_id
      t.string :weekday
      t.datetime :begins_at
      t.datetime :ends_at

      t.timestamps null: false
    end
  end
end
