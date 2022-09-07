# frozen_string_literal: true

module Manage
  class PaymentInfoSerializer < ApplicationSerializer
    fields :ref, :amount, :formatted_ref, :formatted_amount, :iban
  end
end
