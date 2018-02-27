module Ability
  class Base
    include CanCan::Ability

    def initialize(user)
      anonymous_abilities
      return if user.blank?
      user_abilities(user)
      admin_abilities(user) if user.admin?
      manage_abilities(user) if user.user?
    end

    protected

    def admin_abilities(_user)
      can :manage, :all
    end

    def manage_abilities(_user); end

    def user_abilities(_user); end

    def anonymous_abilities; end
  end

  class Admin < Base
  end

  class Manage < Base
    def manage_abilities(_user)
      can :manage, Home
      can :manage, Customer
      can :manage, Booking
      can :manage, Occupancy
    end
  end

  class Public < Base
    def anonymous_abilities
      can %i[create read update], Booking
      can %i[create read update], Customer
    end
  end
end
