class User < ActiveRecord::Base
  self.inheritance_column = :role
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :address, presence: true

  def is_admin?
    self.role == 'Admin'
  end

  def is_patient?
    self.role == 'Patient'
  end

  def is_doctor?
    self.role == 'Doctor'
  end

  def active_for_authentication? 
    super && approved? 
  end 

  def inactive_message 
    if !approved? 
      :not_approved 
    else 
      super # Use whatever other message 
    end 
  end
end