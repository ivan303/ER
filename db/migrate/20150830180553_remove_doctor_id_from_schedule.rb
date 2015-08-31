class RemoveDoctorIdFromSchedule < ActiveRecord::Migration
  def change
    remove_column :schedules, :doctor_id, :integer
  end
end
