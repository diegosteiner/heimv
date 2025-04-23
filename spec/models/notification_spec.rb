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

require 'rails_helper'

RSpec.describe Notification do
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
        notification.save
        expect(notification.to.to_sym).to eq(:tenant)
        expect(notification.resolve_to).to eq(booking.tenant)
        expect(notification.deliver_to).to eq([booking.tenant.email])
        expect(notification.locale).to eq(booking.tenant.locale)
      end
    end

    context 'with booking_agent' do
      let(:booking_agent) { create(:booking_agent, organisation:) }
      let!(:agent_booking) { booking.create_agent_booking(organisation:, booking_agent_code: booking_agent.code) }

      it do
        notification.to = booking_agent
        notification.save
        expect(notification.to.to_sym).to eq(:booking_agent)
        expect(notification.resolve_to).to eq(booking_agent)
        expect(notification.deliver_to).to eq([booking_agent.email])
      end
    end

    context 'with operator' do
      let(:operator) { create(:operator, organisation:, locale: :it) }
      let!(:responsibility) { create(:operator_responsibility, booking:, operator:, responsibility: :home_handover) }

      it do
        notification.to = responsibility
        notification.save
        expect(notification.to.to_sym).to eq(:home_handover)
        expect(notification.resolve_to).to eq(responsibility)
        expect(notification.deliver_to).to eq([operator.email])
        expect(notification.locale).to eq(operator.locale)
      end
    end

    context 'with organisation' do
      it do
        notification.to = :administration
        notification.save
        expect(notification.to.to_sym).to eq(:administration)
        expect(notification.resolve_to).to eq(organisation)
        expect(notification.deliver_to).to eq([organisation.email])
        expect(notification.locale).to eq(organisation.locale)
      end
    end
  end

  describe '#autodeliver' do
    subject(:autodeliver) { notification.autodeliver }

    let(:autodeliver) { nil }
    let(:key) { :test_autodeliver }
    let(:mail_template) { create(:mail_template, key:, organisation: notification.organisation, autodeliver:) }

    before do
      MailTemplate.define(key)
      notification.apply_template(mail_template)
    end

    after { MailTemplate.undefine(key) }

    context 'with autodeliver' do
      let(:autodeliver) { true }

      it { expect(notification).to be_autodeliver }

      it do
        expect(notification).to receive(:deliver).and_return(true)
        expect(notification.autodeliver!).to be_truthy
      end
    end

    context 'without autodeliver' do
      let(:autodeliver) { nil }

      it { expect(notification).not_to be_autodeliver }

      it do
        expect(notification).not_to receive(:deliver)
        expect(notification.autodeliver!).to be_falsy
        expect(notification).to be_persisted
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

  describe '#deliver_to' do
    subject(:deliver_to) { notification.deliver_to }

    let(:tenant) { booking.tenant }
    let(:operator) { create(:operator, organisation:) }
    let(:notification) { build(:notification, to:, booking:, subject: 'Test', body: 'Test Body') }

    context 'with :tenant' do
      let(:to) { :tenant }

      it do
        expect(notification).to be_valid
        is_expected.to eq([tenant.email])
      end
    end

    context 'with tenant' do
      let(:to) { tenant }

      it do
        expect(notification).to be_valid
        is_expected.to eq([tenant.email])
      end
    end

    context 'with tenant but without email' do
      let(:to) { tenant }

      before { booking.email = booking.tenant.email = nil }

      it do
        expect(notification).not_to be_valid
        is_expected.to eq([])
      end
    end

    context 'with :home_handover' do
      let(:to) { :home_handover }

      before { booking.operator_responsibilities.create(operator:, responsibility: :home_handover) }

      it do
        expect(notification).to be_valid
        is_expected.to eq([operator.email])
      end
    end

    context 'with home_handover' do
      let(:to) { booking.operator_responsibilities.create(operator:, responsibility: :home_handover) }

      it do
        expect(notification).to be_valid
        is_expected.to eq([operator.email])
      end
    end

    context 'with operator' do
      let(:to) { operator }

      it do
        expect(notification).to be_valid
        is_expected.to eq([operator.email])
      end
    end

    context 'with email' do
      let(:to) { 'test@example.com' }

      it do
        expect(notification).to be_valid
        is_expected.to eq([to])
      end
    end
  end
end
