# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id                    :bigint           not null, primary key
#  addressed_to          :integer          default("manager"), not null
#  body                  :text
#  cc                    :string           default([]), is an Array
#  locale                :string           default(NULL), not null
#  sent_at               :datetime
#  subject               :string
#  to                    :string           default([]), is an Array
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  booking_id            :uuid
#  rich_text_template_id :bigint
#
# Indexes
#
#  index_notifications_on_booking_id             (booking_id)
#  index_notifications_on_rich_text_template_id  (rich_text_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (rich_text_template_id => rich_text_templates.id)
#

require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:email) { 'test@heimv.local' }
  let(:booking) { create(:booking) }
  let(:notification) { build(:notification, booking: booking, to: email) }

  describe '#save' do
    it { expect(notification.save).to be true }
  end

  describe '#to' do
    let(:notification) { build(:notification, to: to) }
    subject { notification.to }

    context 'with operator' do
      let(:to) { create(:operator) }
      it { is_expected.to eq([to.email]) }
      it { expect(notification).to be_addressed_to_manager }
      it { expect(notification.locale).to eq(to.locale) }
    end

    context 'with organisation' do
      let(:to) { create(:organisation, email: email, locale: :it) }
      it { is_expected.to eq([to.email]) }
      it { expect(notification).to be_addressed_to_manager }
      it { expect(notification.locale).to eq(to.locale) }
    end

    context 'with tenant' do
      let(:to) { create(:tenant, email: email) }
      it { is_expected.to eq([to.email]) }
      it { expect(notification).to be_addressed_to_tenant }
      # it { expect(notification.locale).to eq(to.locale) }
    end

    context 'with booking' do
      let(:to) { create(:booking, email: email, locale: :it) }
      it { is_expected.to eq([to.email]) }
      it { expect(notification).to be_addressed_to_tenant }
      it { expect(notification.locale).to eq(to.locale) }
    end
  end

  describe '#deliver' do
    let(:operator) { create(:operator, locale: :it) }
    let(:notification) { create(:notification, to: email) }
    subject(:message) { notification.deliver }

    it do
      is_expected.to be_truthy
      expect(message.to).to eq(notification.to)
      expect(message.cc).to eq(notification.cc)
      expect(message.subject).to eq(notification.subject)
      expect(notification.sent_at).not_to be nil
    end
  end

  describe '#template' do
    before do
      allow(RichTextTemplate).to receive(:template_key_valid?).and_return(true)
    end

    let(:template) { create(:rich_text_template, key: :test, organisation: booking.organisation) }
    let(:notification) { build(:notification, booking: booking, to: booking) }
    let(:booking) { create(:booking, locale: I18n.locale) }

    context 'with template available' do
      subject(:new_notification) { booking.notifications.new(template: template.key, to: booking) }
      it do
        expect(new_notification.save).to be true
        expect(new_notification.rich_text_template).to eq(template)
        expect(new_notification.body).to eq(template.body)
        expect(new_notification.subject).to eq(template.title)
        expect(new_notification.to).to eq([booking.email])
      end
    end

    context 'without template available' do
      it do
        new_notification = booking.notifications.new(template: :nonexistent, to: booking)
        expect(new_notification.rich_text_template).to be(nil)
        expect(new_notification).not_to be_deliverable
      end
    end
  end
end
