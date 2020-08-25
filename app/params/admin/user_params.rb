# frozen_string_literal: true

module Admin
  class UserParams < ApplicationParams
    def self.permitted_keys
      %i[email role organisation_id]
    end
  end
end
