# frozen_string_literal: true

module Manage
  class NotificationParams < ApplicationParams
    def self.permitted_keys
      %i[subject body sent_at]
    end
  end
end
