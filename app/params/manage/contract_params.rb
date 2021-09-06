# frozen_string_literal: true

module Manage
  class ContractParams < ApplicationParams
    def self.permitted_keys
      %i[sent_at signed_at title text valid_from valid_until booking_id signed_pdf]
    end

    sanitize do |params|
      sanitizer = Rails::Html::SafeListSanitizer.new
      params[:text] = sanitizer.sanitize(params[:text])
      params
    end
  end
end
