module Ability
  class Base
    include CanCan::Ability

    def initialize(user)
      anonymous_abilities
      return if user.blank?

      user_abilities(user)
      # admin_abilities(user) if user.admin?
      manage_abilities(user) # if user.user?
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
    # rubocop:disable Metrics/AbcSize
    def manage_abilities(user)
      organisation = user.organisation
      can :manage, Home, organisation: organisation
      can :manage, DataDigest, organisation: organisation
      can :manage, MarkdownTemplate, organisation: organisation
      can :manage, Tarif, home: { organisation: organisation }
      can :manage, Tarif, booking: { organisation: organisation }
      can :manage, TarifSelector, home: { organisation: organisation }
      can :manage, TarifTarifSelector, home: { organisation: organisation }
      can :manage, Tenant, organisation: organisation
      can :manage, Booking, organisation: organisation
      can :manage, Occupancy, home: { organisation: organisation }
      can :manage, MeterReadingPeriod, home: { organisation: organisation }
      can :manage, BookingAgent, organisation: organisation
      can :manage, Invoice, booking: { organisation: organisation }
      can :manage, Contract, booking: { organisation: organisation }
      can :manage, Payment, booking: { organisation: organisation }
      can :manage, Deadline, booking: { organisation: organisation }
      can :manage, Usage, booking: { organisation: organisation }
      can :manage, Message, booking: { organisation: organisation }
      can %i[read edit update], Organisation, id: organisation.id
    end
    # rubocop:enable Metrics/AbcSize
  end

  class Public < Base
    def anonymous_abilities
      can %i[create read update], AgentBooking
      can %i[create read update], Booking
      can %i[create read update], Tenant
      can %i[read index], Home, requests_allowed: true
      can %i[read index embed], Occupancy, home: { requests_allowed: true }
    end
  end
end
