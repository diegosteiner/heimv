# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint           not null, primary key
#  amount             :decimal(, )      default(0.0)
#  amount_open        :decimal(, )
#  discarded_at       :datetime
#  issued_at          :datetime
#  payable_until      :datetime
#  payment_info_type  :string
#  print_payment_slip :boolean          default(FALSE)
#  ref                :string
#  sent_at            :datetime
#  text               :text
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#
# Indexes
#
#  index_invoices_on_booking_id    (booking_id)
#  index_invoices_on_discarded_at  (discarded_at)
#  index_invoices_on_ref           (ref)
#  index_invoices_on_type          (type)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:invoice) { create(invoice) }

  describe '#ref' do
    it { is_expected.not_to be_blank }
  end

  describe '#payment_info' do
    let(:invoice) { create(:invoice, payment_info_type: PaymentInfos::QrBill.to_s) }
    subject { invoice.payment_info }

    it { is_expected.to be_a(PaymentInfos::QrBill) }
  end
end
