# frozen_string_literal: true

class PaymentInfo
  extend RichTextTemplate::Definition
  extend ActiveModel::Translation
  extend ActiveModel::Naming
  include Subtypeable

  attr_reader :invoice

  delegate :amount, :ref, :invoice_ref_service, :organisation, :booking, to: :invoice
  delegate :iban, to: :organisation

  def initialize(invoice)
    @invoice = invoice
  end

  def show?
    true
  end

  def formatted_ref
    invoice.payment_ref
  end

  def formatted_amount
    format('%<amount>0.2f', amount:)
  end

  def self.human_model_name(...)
    model_name.human(...)
  end

  def to_h
    {
      ref:, amount:, formatted_ref:, iban:, formatted_amount:
    }
  end
end
