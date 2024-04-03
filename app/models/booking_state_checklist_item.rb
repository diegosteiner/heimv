# frozen_string_literal: true

class BookingStateChecklistItem
  ITEMS = {
    invoice_created: lambda do |booking|
      checked = Invoices::Invoice.of(booking).kept.exists?
      url = if checked
              proc { manage_booking_invoices_path(_1.booking) }
            else
              proc { new_manage_booking_invoice_path(_1.booking, invoice: { type: Invoices::Invoice.model_name.to_s }) }
            end

      BookingStateChecklistItem.new(key: :invoice_created, context: { booking: }, checked:, url:)
    end,

    invoices_settled: lambda do |booking|
      BookingStateChecklistItem.new(key: :invoices_settled, context: { booking: },
                                    checked: Invoices::Invoice.of(booking).kept.all?(&:settled?),
                                    url: proc { manage_booking_invoices_path(_1.booking) })
    end,

    deposit_paid: lambda do |booking|
      BookingStateChecklistItem.new(key: :deposit_paid, context: { booking: },
                                    checked: Invoices::Deposit.of(booking).kept.all?(&:paid?),
                                    url: proc { manage_booking_invoices_path(_1.booking) })
    end,

    contract_signed: lambda do |booking|
      BookingStateChecklistItem.new(key: :contract_signed, context: { booking: },
                                    checked: booking.contracts.signed.exists?,
                                    url: proc { manage_booking_contracts_path(_1.booking) })
    end,

    tarifs_chosen: lambda do |booking|
      url = proc { manage_booking_usages_path(_1.booking) }
      BookingStateChecklistItem.new(key: :tarifs_chosen, context: { booking: }, checked: booking.usages.any?, url:)
    end,

    contract_created: lambda do |booking|
      checked = booking.contract.present?
      url = if checked
              proc { manage_booking_contracts_path(_1.booking) }
            else
              proc { new_manage_booking_contract_path(_1.booking) }
            end
      BookingStateChecklistItem.new(key: :contract_created, context: { booking: }, checked:, url:)
    end,

    deposit_created: lambda do |booking|
      checked = Invoices::Deposit.of(booking).kept.exists?
      url = if checked
              proc { manage_booking_invoices_path(_1.booking) }
            else
              proc { new_manage_booking_invoice_path(_1.booking, invoice: { type: Invoices::Deposit.model_name.to_s }) }
            end
      BookingStateChecklistItem.new(key: :deposit_created, context: { booking: }, checked:, url:)
    end,

    offer_created: lambda do |booking|
      return if booking.organisation.rich_text_templates.enabled.by_key(:invoices_offer_text).blank?

      checked = Invoices::Offer.of(booking).kept.exists?
      url = if checked
              proc { manage_booking_invoices_path(_1.booking) }
            else
              proc { new_manage_booking_invoice_path(_1.booking, invoice: { type: Invoices::Offer.model_name.to_s }) }
            end

      BookingStateChecklistItem.new(key: :offer_created, context: { booking: }, checked:, url:)
    end,

    responsibilities_assigned: lambda do |booking|
      return if booking.organisation.operators.none?

      BookingStateChecklistItem.new(key: :responsibilities_assigned, context: { booking: },
                                    checked: booking.roles[:home_handover].present?,
                                    url: proc { manage_booking_operator_responsibilities_path(_1.booking) })
    end,

    usages_entered: lambda do |booking|
      checked = booking.usages.any?(&:updated_after_past?) || Invoices::Invoice.of(booking).kept.exists?
      BookingStateChecklistItem.new(key: :usages_entered, context: { booking: }, checked:,
                                    url: proc { manage_booking_usages_path(_1.booking) })
    end
  }.freeze

  include ActiveModel::Model
  include Translatable
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Attributes

  attribute :key
  attribute :url
  attribute :context, default: -> { {} }
  attribute :checked, default: false

  def label(*)
    translate(key, *)
  end

  def booking
    context&.fetch(:booking, nil)
  end

  def self.prepare(*items, booking:)
    self[*items].map { |key, item_proc| item_proc.call(booking) if items.include?(key) }.compact
  end

  def self.[](*items)
    ITEMS.slice(*items)
  end
end
