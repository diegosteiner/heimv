# frozen_string_literal: true

class DeadlineSettings
  include StoreModel::Model
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attribute :awaiting_contract_deadline, DurationType.new, default: -> { 10.days }
  attribute :awaiting_tenant_deadline, DurationType.new, default: -> { 10.days }
  attribute :overdue_request_deadline, DurationType.new, default: -> { 3.days }
  attribute :payment_overdue_deadline, DurationType.new, default: -> { 3.days }
  attribute :unconfirmed_request_deadline, DurationType.new, default: -> { 3.days }
  attribute :provisional_request_deadline, DurationType.new, default: -> { 10.days }
  attribute :invoice_payment_deadline, DurationType.new, default: -> { 30.days }
  attribute :deposit_payment_deadline, DurationType.new, default: -> { 10.days }
  attribute :deadline_postponable_for, DurationType.new, default: -> { 3.days }

  validates :awaiting_contract_deadline, :awaiting_tenant_deadline, :overdue_request_deadline,
            :payment_overdue_deadline, :unconfirmed_request_deadline, :provisional_request_deadline,
            :invoice_payment_deadline, :deposit_payment_deadline, :deadline_postponable_for,
            numericality: { less_than_or_equal: 5.years, greater_than_or_equal: -1 }
end
