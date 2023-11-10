# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id            :bigint           not null, primary key
#  amount        :decimal(, )
#  data          :jsonb
#  paid_at       :date
#  ref           :string
#  remarks       :text
#  write_off     :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  booking_id    :uuid
#  camt_instr_id :string
#  invoice_id    :bigint
#
# Indexes
#
#  index_payments_on_booking_id  (booking_id)
#  index_payments_on_invoice_id  (invoice_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (invoice_id => invoices.id)
#

require 'rails_helper'

RSpec.describe Payment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
