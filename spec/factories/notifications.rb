# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id               :bigint           not null, primary key
#  body             :text
#  deliver_to       :string           default([]), is an Array
#  delivered_at     :datetime
#  sent_at          :datetime
#  subject          :string
#  to               :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  booking_id       :uuid
#  mail_template_id :bigint
#

FactoryBot.define do
  factory :notification do
    body { '# Body' }
    sent_at { nil }
    subject { 'Subject' }
    to { :tenant }

    booking
  end
end
