# frozen_string_literal: true

module Manage
  class HomeParams < ApplicationParams
    def self.permitted_keys
      %i[name address requests_allowed ref]
    end
  end
end
