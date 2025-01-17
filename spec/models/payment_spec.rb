# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                        :bigint           not null, primary key
#  accounting_account_nr     :string
#  accounting_cost_center_nr :string
#  amount                    :decimal(, )
#  data                      :jsonb
#  paid_at                   :date
#  ref                       :string
#  remarks                   :text
#  write_off                 :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  booking_id                :uuid
#  camt_instr_id             :string
#  invoice_id                :bigint
#

require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:booking) { create(:booking, notifications_enabled: true) }
  let!(:template) do
    create(:mail_template, key: :payment_confirmation_notification,
                           organisation: booking.organisation,
                           body: '{{ payment.amount }}')
  end
  let(:payment) { create(:payment, booking:, invoice: nil, confirm: true) }

  describe '#confirm!' do
    subject(:mail) { payment.confirm! }

    it do
      expect(mail.template_context.keys).to include(*%i[booking payment])
      expect(mail).to be_valid
      expect(mail.body).to include(payment.amount.to_s)
    end
  end
end
