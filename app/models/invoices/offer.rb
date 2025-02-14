# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                   :bigint           not null, primary key
#  amount               :decimal(, )      default(0.0)
#  amount_open          :decimal(, )
#  discarded_at         :datetime
#  issued_at            :datetime
#  locale               :string
#  payable_until        :datetime
#  payment_info_type    :string
#  payment_ref          :string
#  payment_required     :boolean          default(TRUE)
#  ref                  :string
#  sent_at              :datetime
#  sequence_number      :integer
#  sequence_year        :integer
#  status               :integer          default("draft"), not null
#  text                 :text
#  type                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  supersede_invoice_id :bigint
#

module Invoices
  class Offer < ::Invoice
    ::Invoice.register_subtype self do
      scope :offers, -> { where(type: Invoices::Offer.sti_name) }
    end

    def amount_open
      0
    end

    def payment_info
      nil
    end

    def payment_required
      false
    end

    def sequence_number
      self[:sequence_number] ||= organisation.key_sequences.key(Offer.sti_name, year: sequence_year).lease!
    end
  end
end
