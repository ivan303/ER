class Ability
  include CanCan::Ability

  def initialize(user)
      if user.is_admin?
        can :manage, :all
      elsif user.is_doctor?
        # can :manage, Sessions
        can :show, User
      elsif user.is_patient?
        # can :manage, Sessions
        can :show, User
    end
  end
end
