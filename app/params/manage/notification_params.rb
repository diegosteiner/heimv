# frozen_string_literal: true

module Manage
  class NotificationParams < ApplicationParams
    def self.permitted_keys
      %i[subject body to]
    end
  end
end
