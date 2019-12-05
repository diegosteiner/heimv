module Public
  class OrganisationSerializer < ApplicationSerializer
    attributes :name, :address, :booking_strategy_type, :invoice_ref_strategy_type,
               :payment_information, :esr_participant_nr, :message_footer
  end
end
