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
    it { expect(message.save).to be true }
  end

  describe '#deliver' do
    let(:message) { create(:message) }
    subject { message.deliver }

    it do
      is_expected.to be true
      expect(message.sent_at).not_to be nil
    end
  end

  describe 'from_template' do
    let(:template) { create(:markdown_template, organisation: booking.organisation, locale: I18n.locale) }
    let(:message) { build(:message, booking: booking) }
    let(:booking) { create(:booking, locale: I18n.locale) }

    context 'with template available' do
      subject(:new_message) { booking.messages.new(from_template: template.key) }
      it do
        expect(new_message.save).to be true
        expect(new_message.markdown_template).to eq(template)
        expect(new_message.body).to eq(template.body)
        expect(new_message.subject).to eq(template.title)
      end
    end

    context 'without template available' do
      it do
        new_message = booking.messages.new(from_template: :nonexistent)
        expect(new_message.markdown_template).to be(nil)
        expect(new_message).not_to be_deliverable
      end
    end
  end
end
