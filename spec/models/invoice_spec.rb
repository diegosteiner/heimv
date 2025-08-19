# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                        :bigint           not null, primary key
#  amount                    :decimal(, )      default(0.0)
#  balance                   :decimal(, )
#  discarded_at              :datetime
#  issued_at                 :datetime
#  items                     :jsonb
#  locale                    :string
#  payable_until             :datetime
#  payment_info_type         :string
#  payment_ref               :string
#  payment_required          :boolean          default(TRUE)
#  ref                       :string
#  sent_at                   :datetime
#  sequence_number           :integer
#  sequence_year             :integer
#  status                    :integer
#  text                      :text
#  type                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  booking_id                :uuid
#  sent_with_notification_id :bigint
#  supersede_invoice_id      :bigint
#

require 'rails_helper'

RSpec.describe Invoice do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:invoice) { create(:invoice, organisation:) }

  describe '::unsettled' do
    subject(:unsettled) { described_class.unsettled }

    let!(:offer) { create(:invoice, type: Invoices::Offer) }
    let!(:invoice) { create(:invoice) }

    it 'does not list the offer as unsettled' do
      invoice.sent!
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
      Invoice::Factory.new(predecessor.booking).build(type: Invoices::LateNotice, supersede_invoice: predecessor)
    end

    let(:predecessor) do
      create(:invoice, type: Invoices::Invoice).tap do |invoice|
        invoice.payments = build_list(:payment, 1, amount: 100.0)
        invoice.items = build_list(:invoice_item, 2, amount: 100.0)
      end
    end

    it 'discards the old invoice' do
      successor.save
      expect(predecessor).to be_discarded
      expect(successor.type).to eq(Invoices::LateNotice.to_s)
      expect(successor.payment_ref).to eq(predecessor.payment_ref)
    end

    it 'migrates payments and items' do
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
