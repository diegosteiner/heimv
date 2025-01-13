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
#  text                 :text
#  type                 :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  supersede_invoice_id :bigint
#

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:invoice) { create(:invoice, organisation:) }

  describe '::unsettled' do
    let!(:offer) { create(:invoice, type: Invoices::Offer) }
    let!(:invoice) { create(:invoice) }
    subject(:unsettled) { described_class.unsettled }

    it 'does not list the offer as unsettled' do
      is_expected.to include(invoice)
      is_expected.not_to include(offer)
    end
  end

  describe '#payment_info' do
    subject { invoice.payment_info }

    let(:invoice) { create(:invoice, payment_info_type: PaymentInfos::QrBill.to_s) }

    it { is_expected.to be_a(PaymentInfos::QrBill) }
  end

  describe '#supersede' do
    subject(:successor) do
      factory.call(predecessor.booking, type: Invoices::LateNotice, supersede_invoice: predecessor)
    end

    let(:predecessor) do
      create(:invoice, type: Invoices::Invoice).tap do |invoice|
        invoice.payments = build_list(:payment, 1, amount: 100.0)
        invoice.invoice_parts = build_list(:invoice_part, 2, amount: 100.0)
      end
    end
    let(:factory) { Invoice::Factory.new }

    it 'discards the old invoice' do
      successor.save
      expect(predecessor).to be_discarded
      expect(successor.type).to eq(Invoices::LateNotice.to_s)
      expect(successor.payment_ref).to eq(predecessor.payment_ref)
    end

    it 'migrates payments and invoice_parts' do
      successor.save
      expect(predecessor.payments.reload).to be_blank
      expect(successor.payments.count).to eq(1)
    end

    describe '#ref' do
      let(:current_year) { Time.zone.today.year }
      let(:year) { current_year - 2000 }
      it 'tracks sequence' do
        expect(create(:invoice, organisation:)).to have_attributes(sequence_year: current_year,
                                                                   sequence_number: 1,
                                                                   ref: "#{year}0001")
        expect(create(:invoice, organisation:)).to have_attributes(sequence_number: 2,
                                                                   ref: "#{year}0002")
      end
    end
  end
end
