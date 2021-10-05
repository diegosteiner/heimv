# frozen_string_literal: true

module Manage
  class OperatorParams < ApplicationParams
    def self.permitted_keys
      %i[name email contact_info]
    end
  end
end
