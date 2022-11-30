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
#  payable_until        :datetime
#  payment_info_type    :string
#  ref                  :string
#  sent_at              :datetime
#  text                 :text
#  type                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  supersede_invoice_id :bigint
#
# Indexes
#
#  index_invoices_on_booking_id            (booking_id)
#  index_invoices_on_discarded_at          (discarded_at)
#  index_invoices_on_ref                   (ref)
#  index_invoices_on_supersede_invoice_id  (supersede_invoice_id)
#  index_invoices_on_type                  (type)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (supersede_invoice_id => invoices.id)
#

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:invoice) { create(:invoice) }

  describe '#ref' do
    it { is_expected.not_to be_blank }
  end

  describe '#payment_info' do
    let(:invoice) { create(:invoice, payment_info_type: PaymentInfos::QrBill.to_s) }
    subject { invoice.payment_info }

    it { is_expected.to be_a(PaymentInfos::QrBill) }
  end

  describe '#supersede' do
    let(:predecessor) do
      create(:invoice, type: Invoices::Invoice).tap do |invoice|
        invoice.payments = build_list(:payment, 1, amount: 100.0)
        invoice.invoice_parts = build_list(:invoice_part, 2, amount: 100.0)
      end
    end
    let(:factory) { Invoices::Factory.new }
    subject(:successor) do
      factory.call(predecessor.booking, type: Invoices::LateNotice, supersede_invoice: predecessor)
    end

    it 'discards the old invoice' do
      successor.save
      expect(predecessor).to be_discarded
      expect(successor.type).to eq(Invoices::LateNotice.to_s)
      expect(successor.ref).to eq(predecessor.ref)
    end

    it 'migrates payments and invoice_parts' do
      successor.save
      expect(predecessor.payments.reload).to be_blank
      expect(successor.payments.count).to eq(1)
    end
  end
end
