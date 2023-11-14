# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id               :bigint           not null, primary key
#  addressed_to     :string           default(NULL)
#  bcc              :string
#  body             :text
#  cc               :string           default([]), is an Array
#  locale           :string           default(NULL), not null
#  sent_at          :datetime
#  subject          :string
#  template_context :text
#  to               :string           default([]), is an Array
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

require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:email) { 'test@heimv.local' }
  let(:booking) { create(:booking) }
  let(:notification) { build(:notification, booking:, to: email) }

  describe '#save' do
    it { expect(notification.save).to be true }
  end

  describe '#to' do
    subject { notification.to }

    let(:notification) { build(:notification, to:) }

    context 'with operator' do
      let(:to) { create(:operator) }

      it { is_expected.to eq([to.email]) }
      it { expect(notification.locale).to eq(to.locale) }
    end

    context 'with organisation' do
      let(:to) { create(:organisation, email:, locale: :it) }

      it { is_expected.to eq([to.email]) }
      it { expect(notification.locale).to eq(to.locale) }
    end

    context 'with tenant' do
      let(:to) { create(:tenant, email:) }

      it { is_expected.to eq([to.email]) }
      it { expect(notification.locale).to eq(to.locale) }
    end

    context 'with booking' do
      let(:to) { create(:booking, email:, locale: :it) }

      it { is_expected.to eq([to.email]) }
      it { expect(notification.locale).to eq(to.locale) }
    end
  end

  describe '#deliver' do
    subject(:message) { notification.deliver }

    let(:operator) { create(:operator, locale: :it) }
    let(:notification) { create(:notification, to: email) }

    it do
      expect(notification.sent_at).to be_nil
      expect { message }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(message.to).to eq(notification.to)
      expect(message.cc).to eq(notification.cc)
      expect(message.subject).to eq(notification.subject)
      notification.reload
      expect(notification.sent_at).not_to be_nil
    end
  end
end
