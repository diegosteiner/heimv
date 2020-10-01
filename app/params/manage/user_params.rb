# frozen_string_literal: true

module Manage
  class UserParams < ApplicationParams
    def self.permitted_keys
      %i[email role]
    end
  end
end
