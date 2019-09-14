# == Schema Information
#
# Table name: messages
#
#  id                   :bigint           not null, primary key
#  booking_id           :uuid
#  markdown_template_id :bigint
#  sent_at              :datetime
#  subject              :string
#  body                 :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

FactoryBot.define do
  factory :message do
    body { 'MyText' }
    sent_at { '2018-10-23 14:08:21' }
    subject { 'MyString' }

    booking { nil }
  end
end
