# frozen_string_literal: true

module Admin
  class OrganisationParams < Manage::OrganisationParams
    def self.permitted_keys
      super + %i[booking_strategy_type invoice_ref_strategy_type domain messages_enabled smtp_url]
    end
  end
end
