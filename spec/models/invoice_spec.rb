# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint(8)        not null, primary key
#  booking_id         :uuid
#  issued_at          :datetime
#  payable_until      :datetime
#  sent_at            :datetime
#  text               :text
#  invoice_type       :integer
#  esr_number         :string
#  amount             :decimal(, )      default(0.0)
#  paid               :boolean          default(FALSE)
#  print_payment_slip :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
