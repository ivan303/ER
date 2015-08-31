class RemoveClinicIdFromSchedule < ActiveRecord::Migration
  def change
    remove_column :schedules, :clinic_id, :integer
  end
end
