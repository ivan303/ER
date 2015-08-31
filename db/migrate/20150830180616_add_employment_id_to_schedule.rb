class AddEmploymentIdToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :employment_id, :integer
  end
end
