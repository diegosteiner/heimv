# frozen_string_literal: true

module BookingStates
  class DefinitiveRequest < Base
    RichTextTemplate.require_template(:definitive_request_notification, template_context: %i[booking],
                                                                        required_by: self)
    RichTextTemplate.require_template(:manage_definitive_request_notification, template_context: %i[booking],
                                                                               required_by: self, optional: true)
    include Rails.application.routes.url_helpers

    def checklist
      [
        assign_responsibilities_checklist_item,
        choose_tarifs_checklist_item,
        create_deposit_checklist_item,
        create_offer_checklist_item,
        create_contract_checklist_item
      ].compact
    end

    def invoice_type
      Invoices::Deposit
    end

    def self.to_sym
      :definitive_request
    end

    guard_transition do |booking|
      booking.tenant&.valid?
    end

    infer_transition(to: :upcoming) do |booking|
      booking.contracts.sent.none? && booking.tenant&.allow_bookings_without_contract
    end

    infer_transition(to: :awaiting_contract) do |booking|
      booking.contracts.sent.any?
    end

    after_transition do |booking|
      if occupied_occupancy_state?(booking)
        booking.occupied!
      elsif !booking.occupied?
        booking.tentative!
      end
    end

    after_transition do |booking|
      booking.update!(editable: false, committed_request: true)
      booking.deadline&.clear
      OperatorResponsibility.assign(booking, :home_handover, :home_return)
      to = booking.responsibilities[:administration] || booking.organisation
      booking.notifications.new(template: :manage_definitive_request_notification, to:)&.deliver
      booking.notifications.new(template: :definitive_request_notification, to: booking.tenant).deliver
    end

    def relevant_time
      booking.created_at
    end

    protected

    def choose_tarifs_checklist_item
      ChecklistItem.new(:choose_tarifs, booking.usages.any?,
                        manage_booking_usages_path(
                          booking, org: booking.organisation, locale: I18n.locale
                        ))
    end

    def create_contract_checklist_item
      checked = booking.contract.present?
      default_params = { org: booking.organisation, locale: I18n.locale }
      ChecklistItem.new(:create_contract, checked,
                        (checked &&
                          manage_booking_contracts_path(booking, **default_params)) ||
                        new_manage_booking_contract_path(booking, **default_params))
    end

    def checklist_invoice_path(booking, checked, type)
      default_params = { org: booking.organisation, locale: I18n.locale }
      return manage_booking_invoices_path(booking, **default_params) if checked

      new_manage_booking_invoice_path(booking,
                                      **default_params.merge({ invoice: { type: type.model_name.to_s } }))
    end

    def create_deposit_checklist_item
      checked = Invoices::Deposit.of(booking).kept.exists?
      ChecklistItem.new(:create_deposit, checked, checklist_invoice_path(booking, checked, Invoices::Deposit))
    end

    def create_offer_checklist_item
      return if booking.organisation.rich_text_templates.enabled.by_key(:invoices_offer_text).blank?

      checked = Invoices::Offer.of(booking).kept.exists?
      ChecklistItem.new(:create_offer, checked, checklist_invoice_path(booking, checked, Invoices::Offer))
    end

    def assign_responsibilities_checklist_item
      return if booking.organisation.operators.none?

      ChecklistItem.new(:assign_responsibilities, booking.responsibilities[:home_handover].present?,
                        manage_booking_operator_responsibilities_path(booking, org: booking.organisation))
    end
  end
end
