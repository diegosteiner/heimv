# frozen_string_literal: true

module Manage
  class MessageParams < ApplicationParams
    def self.permitted_keys
      %i[subject body sent_at]
    end
  end
end
