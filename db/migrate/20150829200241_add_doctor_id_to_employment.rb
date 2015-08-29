class AddDoctorIdToEmployment < ActiveRecord::Migration
  def change
    add_column :employments, :doctor_id, :integer
  end
end
