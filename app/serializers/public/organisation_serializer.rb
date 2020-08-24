# frozen_string_literal: true

module Public
  class OrganisationSerializer < ApplicationSerializer
    attributes :name, :address, :booking_strategy_type, :invoice_ref_strategy_type, :location, :slug,
               :esr_participant_nr, :message_footer, :email, :payment_deadline, :messages_enabled
  end
end
