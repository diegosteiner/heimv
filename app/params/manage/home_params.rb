# frozen_string_literal: true

module Manage
  class HomeParams < ApplicationParams
    def self.permitted_keys
      [:name, :address, :requests_allowed, :ref, {
        tarifs_attributes: TarifParams.permitted_keys + [:id],
        settings: %i[booking_margin booking_window awaiting_contract_deadline overdue_request_deadline
                     unconfirmed_request_deadline provisional_request_deadline last_minute_warning upcoming_soon_window
                     invoice_payment_deadline deposit_payment_deadline deadline_postponable_for occupied_occupancy_color
                     tentative_occupancy_color closed_occupancy_color]
      }]
    end
  end
end
