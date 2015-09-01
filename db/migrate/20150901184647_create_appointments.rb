class CreateAppointments < ActiveRecord::Migration
  def change
    create_table :appointments do |t|
      t.integer :patient_id
      t.integer :schedule_id
      t.datetime :begins_at
      t.datetime :ends_at
      t.datetime :confirmed_at

      t.timestamps null: false
    end
  end
end
