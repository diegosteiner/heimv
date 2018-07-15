  module Manage
    class BookingAgentParams < ApplicationParams
      def self.permitted_keys
        %i[name code email address provision]
      end
    end
  end
