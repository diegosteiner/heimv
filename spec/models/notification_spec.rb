# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications
#
#  id               :bigint           not null, primary key
#  bcc              :string
#  body             :text
#  cc               :string           default([]), is an Array
#  deliver_to       :string           default([]), is an Array
#  locale           :string           default(NULL), not null
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

require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:booking) { create(:booking, locale: :it, organisation:) }
  let(:organisation) { create(:organisation, locale: :fr) }
  let(:notification) { build(:notification, booking:, to: :tenant) }

  describe '#save' do
    it { expect(notification.save).to be true }
  end

  describe '#to' do
    subject(:to) { notification.to }

    context 'with tenant' do
      it do
        notification.to = booking.tenant
        expect(notification.to).to eq(booking.tenant)
        notification.save
        expect(notification.to_in_database).to eq('tenant')
        expect(notification.deliver_to).to eq([booking.tenant.email])
        expect(notification.locale).to eq(booking.tenant.locale)
      end
    end

    context 'with booking_agent' do
      let(:booking_agent) { create(:booking_agent, organisation:) }
      let!(:agent_booking) { booking.create_agent_booking(organisation:, booking_agent_code: booking_agent.code) }
      it do
        notification.to = booking_agent
        expect(notification.to).to eq(booking_agent)
        notification.save
        expect(notification.to_in_database).to eq('booking_agent')
        expect(notification.deliver_to).to eq([booking_agent.email])
        # expect(notification.locale).to eq(booking_agent.locale)
      end
    end

    context 'with operator' do
      let(:operator) { create(:operator, organisation:, locale: :it) }
      let!(:responsibility) { create(:operator_responsibility, booking:, operator:, responsibility: :home_handover) }

      it do
        notification.to = responsibility
        expect(notification.to).to eq(responsibility)
        notification.save
        expect(notification.to_in_database).to eq('home_handover')
        expect(notification.deliver_to).to eq([operator.email])
        expect(notification.locale).to eq(operator.locale)
      end
    end

    context 'with organisation' do
      it do
        notification.to = :administration
        expect(notification.to).to eq(organisation)
        notification.save
        expect(notification.to_in_database).to eq('administration')
        expect(notification.deliver_to).to eq([organisation.email])
        expect(notification.locale).to eq(organisation.locale)
      end
    end
  end

  describe '#deliver' do
    subject(:message) { notification.deliver }

    let(:tenant) { booking.tenant }
    let(:notification) { create(:notification, to: :tenant, booking:, subject: 'Test', body: 'Test Body') }

    it do
      expect(notification.sent_at).to be_nil
      expect { message }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(message.to).to eq([tenant.email])
      expect(message.subject).to eq(notification.subject)
      expect(message.text_part.decoded).to eq(notification.body)
      notification.reload
      expect(notification.sent_at).not_to be_nil
    end
  end
end
