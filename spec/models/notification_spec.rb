# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id                   :bigint           not null, primary key
#  addressed_to         :integer          default("manager"), not null
#  body                 :text
#  cc                   :string           default([]), is an Array
#  queued_for_delivery  :boolean          default(FALSE)
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
#  index_notifications_on_booking_id            (booking_id)
#  index_notifications_on_markdown_template_id  (markdown_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (markdown_template_id => markdown_templates.id)
#

require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:notification) { build(:notification) }

  describe '#save' do
    it { expect(notification.save).to be true }
  end

  describe '#deliver' do
    let(:notification) { create(:notification) }
    subject { notification.deliver }

    it do
      is_expected.to be true
      expect(notification.sent_at).not_to be nil
    end
  end

  describe 'from_template' do
    let(:template) { create(:markdown_template, organisation: booking.organisation) }
    let(:notification) { build(:notification, booking: booking) }
    let(:booking) { create(:booking, locale: I18n.locale) }

    context 'with template available' do
      subject(:new_notification) { booking.notifications.new(from_template: template.key) }
      it do
        expect(new_notification.save).to be true
        expect(new_notification.markdown_template).to eq(template)
        expect(new_notification.body).to eq(template.body)
        expect(new_notification.subject).to eq(template.title)
      end
    end

    context 'without template available' do
      it do
        new_notification = booking.notifications.new(from_template: :nonexistent)
        expect(new_notification.markdown_template).to be(nil)
        expect(new_notification).not_to be_deliverable
      end
    end
  end
end
