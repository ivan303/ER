class AddClinicIdToEmployment < ActiveRecord::Migration
  def change
    add_column :employments, :clinic_id, :integer
  end
end
