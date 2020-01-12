module Public
  class OrganisationSerializer < ApplicationSerializer
    attributes :name, :address, :booking_strategy_type, :invoice_ref_strategy_type,
               :esr_participant_nr, :message_footer, :email
  end
end
