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
# Indexes
#
#  index_notifications_on_booking_id        (booking_id)
#  index_notifications_on_mail_template_id  (mail_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (mail_template_id => rich_text_templates.id)
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
