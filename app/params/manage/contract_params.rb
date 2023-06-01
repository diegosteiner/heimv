# frozen_string_literal: true

module Manage
  class ContractParams < ApplicationParams
    def self.permitted_keys
      %i[sent_at signed_at title text valid_from valid_until booking_id signed_pdf locale]
    end

    sanitize do |params|
      params[:text] = RichTextSanitizer.sanitize(params[:text]) if params[:text].present?
      params
    end
  end
end
