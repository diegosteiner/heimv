# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id                   :bigint           not null, primary key
#  addressed_to         :integer          default("manager"), not null
#  body                 :text
#  cc                   :string           default([]), is an Array
#  sent_at              :datetime
#  subject              :string
#  to                   :string           default([]), is an Array
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  markdown_template_id :bigint
#
# Indexes
#
#  index_messages_on_booking_id            (booking_id)
#  index_messages_on_markdown_template_id  (markdown_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (markdown_template_id => markdown_templates.id)
#

require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:message) { build(:message) }

  describe '#save' do
    it do
      expect(message.save).to be true
    end
  end

  describe '#deliver' do
    let(:message) { create(:message) }
    subject { message.deliver }

    it do
      is_expected.to be true
      expect(message.sent_at).not_to be nil
    end
  end
end
