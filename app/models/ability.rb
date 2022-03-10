# frozen_string_literal: true

module Ability
  class Base
    include CanCan::Ability

    def self.roles
      @roles ||= (superclass.ancestors.include?(Base) && superclass.roles.dup) || {}
    end

    def self.role(*role, &block)
      role.flatten.each { roles[_1&.to_sym] = block }
    end

    def initialize(user, organisation = nil)
      can :set_password, User, id: user.id if user.present?
      abilities_block = self.class.roles[user&.role&.to_sym]
      instance_exec(user, organisation, &abilities_block) if abilities_block
    end

    role :admin do
      can :manage, :all
    end
  end

  class Manage < Base
    role :manager do |user, organisation|
      next unless organisation == user.organisation

      can :manage, Home, organisation: organisation
      can :manage, BookingPurpose, organisation: organisation
      can :manage, DataDigest, organisation: organisation
      can :manage, RichTextTemplate, organisation: organisation
      can :manage, Tarif, home: { organisation: organisation }
      can :manage, Tarif, booking: { organisation: organisation }
      can :manage, TarifSelector, home: { organisation: organisation }
      can :manage, Tenant, organisation: organisation
      can :manage, Booking, organisation: organisation
      can :manage, Occupancy, home: { organisation: organisation }
      can :manage, MeterReadingPeriod, home: { organisation: organisation }
      can :manage, BookingAgent, organisation: organisation
      can :manage, Invoice, booking: { organisation: organisation }
      can :manage, InvoicePart, invoice: { booking: { organisation: organisation } }
      can :manage, Contract, booking: { organisation: organisation }
      can :manage, Offer, booking: { organisation: organisation }
      can :manage, Payment, booking: { organisation: organisation }
      can :manage, Deadline, booking: { organisation: organisation }
      can :manage, Usage, booking: { organisation: organisation }
      can :manage, User, organisation: organisation
      can :manage, Operator, organisation: organisation
      can :manage, OperatorResponsibility, organisation: organisation
      can :manage, Notification, booking: { organisation: organisation }
      can :manage, DesignatedDocument, organisation: organisation
      can :manage, BookableExtra, organisation: organisation
      can %i[read edit update], Organisation, id: organisation.id

      cannot :manage, User, role: :admin
    end

    role :readonly do |user, organisation|
      next unless organisation == user.organisation

      can :read, Home, organisation: organisation
      can :read, BookingPurpose, organisation: organisation
      can %i[read digest], DataDigest, organisation: organisation
      can :read, RichTextTemplate, organisation: organisation
      can :read, Tarif, home: { organisation: organisation }
      can :read, Tarif, booking: { organisation: organisation }
      can :read, TarifSelector, home: { organisation: organisation }
      can :read, Tenant, organisation: organisation
      can :read, Booking, organisation: organisation
      can :read, Occupancy, home: { organisation: organisation }
      can :read, MeterReadingPeriod, home: { organisation: organisation }
      can :read, BookingAgent, organisation: organisation
      can :read, Invoice, booking: { organisation: organisation }
      can :read, InvoicePart, invoice: { booking: { organisation: organisation } }
      can :read, Contract, booking: { organisation: organisation }
      can :read, Offer, booking: { organisation: organisation }
      can :read, Payment, booking: { organisation: organisation }
      can :read, Deadline, booking: { organisation: organisation }
      can :read, Usage, booking: { organisation: organisation }
      can :read, User, organisation: organisation
      can :read, Notification, booking: { organisation: organisation }
      can :read, Operator, organisation: organisation
      can :read, OperatorResponsibility, organisation: organisation
      can %i[read edit], Organisation, id: organisation.id
      cannot %i[update], Organisation, id: organisation.id
    end
  end

  class Public < Base
    role nil do |_user, organisation|
      can :read, Home, { organisation: organisation, requests_allowed: true }

      can %i[read embed calendar at], Occupancy, home: { requests_allowed: true, organisation: organisation }

      can %i[create read update], AgentBooking, { organisation: organisation }
      can %i[create read update], Booking, { organisation: organisation, concluded: false }
    end

    role :readonly do |_user, organisation|
      can :read, Home, { organisation: organisation }
      can :read, Organisation, id: organisation.id

      can %i[read embed calendar at], Occupancy, home: { organisation: organisation }

      can %i[create read update], AgentBooking, { organisation: organisation }
      can %i[create read update], Booking, { organisation: organisation, concluded: false }
    end

    role :manager do |_user, organisation|
      can :manage, Home, { organisation: organisation }
      can :manage, Organisation, id: organisation.id
      can :manage, Occupancy, home: { organisation: organisation }
      can :manage, AgentBooking, { organisation: organisation }
      can :manage, Booking, { organisation: organisation }
    end
  end
end
