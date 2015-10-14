class Ability
  include CanCan::Ability

  def initialize(user)
      if user.is_admin?
        can :manage, :all
      elsif user.is_doctor?
        # can :manage, Sessions
        can :show, User
        can :index, Schedule
        can :destroy, Schedule
        can :create, Schedule

        can :index, Appointment # TEMPORARY, LATER ONLY FOR PATIENTS
      elsif user.is_patient?
        # can :manage, Sessions
        can :show, User
    end
  end
end
