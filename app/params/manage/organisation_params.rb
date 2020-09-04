# frozen_string_literal: true

module Manage
  class OrganisationParams < ApplicationParams
    def self.permitted_keys
      %i[name address
         esr_participant_nr notification_footer logo location bcc
         privacy_statement_pdf terms_pdf iban mail_from
         representative_address contract_signature email]
    end
  end
end
