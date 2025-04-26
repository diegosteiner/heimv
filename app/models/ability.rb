# frozen_string_literal: true

module Ability
  class Base
    include CanCan::Ability

    def self.roles
      @roles ||= (superclass.ancestors.include?(Base) && superclass.roles.dup) || {}
    end

    def self.role(*role, &block)
      role.flatten.each { roles[it&.to_sym] = block }
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

      can(:manage, BookingAgent, organisation:)
      can(:manage, BookingCategory, organisation:)
      can(:manage, BookingCondition, tarif: { organisation: })
      can(:manage, BookingQuestion, organisation:)
      can(:manage, BookingValidation, organisation:)
      can(:manage, DesignatedDocument, organisation:)
      can(:manage, Occupiable, organisation:)
      can(:manage, Operator, organisation:)
      can(%i[read edit update], Organisation, id: organisation.id)
      can(:manage, OrganisationUser, organisation:)
      can(:manage, Tarif, organisation:)
      can(:manage, VatCategory, organisation:)
      can(:manage, JournalEntry, invoice: { booking: { organisation: } })
      can(:new, JournalEntry)
    end

    role :manager do |user, organisation|
      next unless user.in_organisation?(organisation)

      abilities_for_role(:readonly, user, organisation)

      can(:manage, Booking, organisation:)
      can(:manage, Contract, booking: { organisation: })
      can(:manage, DataDigest, organisation:)
      can(:manage, DataDigestTemplate, organisation:)
      can(:manage, Deadline, booking: { organisation: })
      can(:manage, Invoice, booking: { organisation: })
      can(:manage, InvoicePart, invoice: { booking: { organisation: } })
      can(:manage, Notification, booking: { organisation: })
      can(:new, Occupancy)
      can(:manage, Occupancy, occupiable: { organisation: })
      can(:manage, OperatorResponsibility, organisation:)
      can(:manage, Payment, booking: { organisation: })
      can(:manage, Tenant, organisation:)
      can(:manage, Usage, booking: { organisation: })
      can(:manage, RichTextTemplate, organisation:)
      can(:read, PlanBBackup, organisation:)
      can(:read, JournalEntry, invoice: { booking: { organisation: } })
    end

    role :finance do |user, organisation|
      next unless user.in_organisation?(organisation)

      abilities_for_role(:readonly, user, organisation)
      can(:manage, Payment, booking: { organisation: })
      can(:manage, Invoice, booking: { organisation: })
      can(:manage, InvoicePart, invoice: { booking: { organisation: } })
      can(:manage, Tenant, organisation:)
      can(:manage, VatCategory, organisation:)
      can(:manage, JournalEntry, invoice: { booking: { organisation: } })
      can(:new, JournalEntry)
    end

    role :readonly do |user, organisation|
      next unless user.in_organisation?(organisation)

      can(%i[read calendar], Booking, organisation:)
      can(:read, BookingAgent, organisation:)
      can(:read, BookingCategory, organisation:)
      can(:read, BookingCondition, tarif: { organisation: })
      can(:read, BookingQuestion, organisation:)
      can(:read, BookingValidation, organisation:)
      can(:read, Contract, booking: { organisation: })
      can(%i[read new create], DataDigest, organisation:)
      can(:read, DataDigestTemplate, organisation:)
      can(:read, Deadline, booking: { organisation: })
      can(%i[read calendar at embed], Home, organisation:)
      can(:read, Invoice, booking: { organisation: })
      can(:read, InvoicePart, invoice: { booking: { organisation: } })
      can(:read, Notification, booking: { organisation: })
      can(%i[read calendar at embed], Occupancy, occupiable: { organisation: })
      can(%i[read calendar], Occupiable, organisation:)
      can(:read, Operator, organisation:)
      can(:read, OperatorResponsibility, organisation:)
      can(%i[read edit], Organisation, id: organisation.id)
      can(:read, Payment, booking: { organisation: })
      can(:read, RichTextTemplate, organisation:)
      can(:read, Tarif, organisation:)
      can(:read, Tenant, organisation:)
      can(:read, Usage, booking: { organisation: })
      can(:read, User, organisation:)
      can(:read, VatCategory, organisation:)
    end
  end

  class Public < Base
    role nil do |_user, organisation|
      can :read, Home, { organisation:, discarded_at: nil }
      can :read, Occupiable, { organisation:, discarded_at: nil }

      can %i[read embed calendar at], Occupancy, occupiable: { discarded_at: nil, organisation: }

      can %i[create read update], AgentBooking, { organisation: }
      can %i[create read update], Booking, { organisation:, concluded: false }
    end

    role :readonly do |_user, organisation|
      can :read, Home, { organisation: }
      can :read, Occupiable, { organisation: }
      can :read, Organisation, id: organisation.id

      can %i[read embed calendar at], Occupancy, occupiable: { organisation: }

      can %i[create read update], AgentBooking, { organisation: }
      can %i[create read update], Booking, { organisation:, concluded: false }
    end

    role :manager do |user, organisation|
      abilities_for_role(:readonly, user, organisation)

      can :manage, Occupancy, occupiable: { organisation: }
      can :manage, AgentBooking, { organisation: }
      can :manage, Booking, { organisation: }
    end

    role :admin do |user, organisation|
      abilities_for_role(:manager, user, organisation)
    end
  end
end
