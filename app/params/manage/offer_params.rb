# frozen_string_literal: true

module Manage
  class OfferParams < ApplicationParams
    def self.permitted_keys
      %i[text valid_from valid_until]
    end
  end
end
