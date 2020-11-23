# frozen_string_literal: true

module Ability
  class Base
    include CanCan::Ability

    def initialize(user, organisation = nil)
      anonymous_abilities(organisation)
      return if user.blank?

      user_abilities(user, organisation)
      admin_abilities(user, organisation) if user.role_admin?
      manage_abilities(user, organisation) if user.role_manager?
    end

    protected

    def admin_abilities(_user, _organisation)
      can :manage, :all
    end

    def manage_abilities(_user, _organisation); end

    def user_abilities(_user, _organisation); end

    def anonymous_abilities(_organisation); end
  end

  class Admin < Base
  end

  class Manage < Base
    # rubocop:disable Metrics/AbcSize
    def manage_abilities(user, organisation)
      return unless organisation == user.organisation

      can :manage, Home, organisation: organisation
      can :manage, DataDigest, organisation: organisation
      can :manage, MarkdownTemplate, organisation: organisation
      can :manage, Tarif, home: { organisation: organisation }
      can :manage, Tarif, booking: { organisation: organisation }
      can :manage, TarifSelector, home: { organisation: organisation }
      can :manage, Tenant, organisation: organisation
      can :manage, Booking, organisation: organisation
      can :manage, Occupancy, home: { organisation: organisation }
      can :manage, MeterReadingPeriod, home: { organisation: organisation }
      can :manage, BookingAgent, organisation: organisation
      can :manage, Invoice, booking: { organisation: organisation }
      can :manage, InvoicePart, booking: { organisation: organisation }
      can :manage, Contract, booking: { organisation: organisation }
      can :manage, Offer, booking: { organisation: organisation }
      can :manage, Payment, booking: { organisation: organisation }
      can :manage, Deadline, booking: { organisation: organisation }
      can :manage, Usage, booking: { organisation: organisation }
      # can :manage, User, organisation: organisation
      cannot :manage, User, role: :admin
      can :manage, Notification, booking: { organisation: organisation }
      can %i[read edit update], Organisation, id: organisation.id
    end
    # rubocop:enable Metrics/AbcSize
  end

  class Public < Base
    def anonymous_abilities(_organisation)
      can %i[create read update], AgentBooking
      can %i[create read update], Booking
      can %i[create read update], Tenant
      can %i[read index], Home, requests_allowed: true
      can %i[read], Organisation
      can %i[read index embed calendar at], Occupancy, home: { requests_allowed: true }
    end

    def manage_abilities(user, _organisation)
      can :manage, Home, organisation: user.organisation
    end
  end
end
