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
      can :manage, :all if user&.role_admin?

      abilities_for_role(user&.in_organisation(organisation)&.role&.to_sym, user, organisation)
    end

    def abilities_for_role(role, user, organisation)
      abilities_block = self.class.roles[role]
      instance_exec(user, organisation, &abilities_block) if abilities_block
    end
  end

  class Manage < Base
    role :admin do |user, organisation|
      next unless user.in_organisation?(organisation)

      abilities_for_role(:manager, user, organisation)

      can :manage, BookingAgent, organisation: organisation
      can :manage, BookingCategory, organisation: organisation
      can :manage, BookingCondition, tarif: { organisation: organisation }
      can :manage, BookableExtra, organisation: organisation
      can :manage, DesignatedDocument, organisation: organisation
      can :manage, Occupiable, organisation: organisation
      can :manage, Operator, organisation: organisation
      can %i[read edit update], Organisation, id: organisation.id
      can :manage, OrganisationUser, organisation: organisation
      can :manage, RichTextTemplate, organisation: organisation
      can :manage, Tarif, organisation: organisation
    end

    role :manager do |user, organisation|
      next unless user.in_organisation?(organisation)

      abilities_for_role(:readonly, user, organisation)

      can :manage, Booking, organisation: organisation
      can :manage, Contract, booking: { organisation: organisation }
      can :manage, DataDigest, organisation: organisation
      can :manage, DataDigestTemplate, organisation: organisation
      can :manage, Deadline, booking: { organisation: organisation }
      can :manage, Invoice, booking: { organisation: organisation }
      can :manage, InvoicePart, invoice: { booking: { organisation: organisation } }
      can :manage, Notification, booking: { organisation: organisation }
      can :manage, Occupancy, occupiable: { organisation: organisation }
      can :manage, OperatorResponsibility, organisation: organisation
      can :manage, Payment, booking: { organisation: organisation }
      can :manage, Tenant, organisation: organisation
      can :manage, Usage, booking: { organisation: organisation }
    end

    role :readonly do |user, organisation|
      next unless user.in_organisation?(organisation)

      can :read, Booking, organisation: organisation
      can :read, BookingAgent, organisation: organisation
      can :read, BookingCategory, organisation: organisation
      can :read, BookingCondition, tarif: { organisation: organisation }
      can :read, Contract, booking: { organisation: organisation }
      can %i[read new create], DataDigest, organisation: organisation
      can :read, DataDigestTemplate, organisation: organisation
      can :read, Deadline, booking: { organisation: organisation }
      can %i[read calendar at embed], Home, organisation: organisation
      can :read, Invoice, booking: { organisation: organisation }
      can :read, InvoicePart, invoice: { booking: { organisation: organisation } }
      can :read, Notification, booking: { organisation: organisation }
      can %i[read calendar at embed], Occupancy, occupiable: { organisation: organisation }
      can :read, Occupiable, organisation: organisation
      can :read, Operator, organisation: organisation
      can :read, OperatorResponsibility, organisation: organisation
      can %i[read edit], Organisation, id: organisation.id
      can :read, Payment, booking: { organisation: organisation }
      can :read, RichTextTemplate, organisation: organisation
      can :read, Tarif, organisation: organisation
      can :read, Tenant, organisation: organisation
      can :read, Usage, booking: { organisation: organisation }
      can :read, User, organisation: organisation
    end
  end

  class Public < Base
    role nil do |_user, organisation|
      can :read, Home, { organisation: organisation, active: true }

      can %i[read embed calendar at], Occupancy, occupiable: { active: true, organisation: organisation }

      can %i[create read update], AgentBooking, { organisation: organisation }
      can %i[create read update], Booking, { organisation: organisation, concluded: false }
    end

    role :readonly do |_user, organisation|
      can :read, Home, { organisation: organisation }
      can :read, Organisation, id: organisation.id

      can %i[read embed calendar at], Occupancy, occupiable: { organisation: organisation }

      can %i[create read update], AgentBooking, { organisation: organisation }
      can %i[create read update], Booking, { organisation: organisation, concluded: false }
    end

    role :manager do |user, organisation|
      abilities_for_role(:readonly, user, organisation)

      can :manage, Occupancy, occupiable: { organisation: organisation }
      can :manage, AgentBooking, { organisation: organisation }
      can :manage, Booking, { organisation: organisation }
    end

    role :admin do |user, organisation|
      abilities_for_role(:manager, user, organisation)
    end
  end
end
