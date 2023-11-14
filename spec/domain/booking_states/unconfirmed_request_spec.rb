# frozen_string_literal: true

require 'rails_helper'

describe BookingStates::UnconfirmedRequest do
  let(:booking_flow) { booking.booking_flow }
  let!(:organisation) { create(:organisation, :with_templates, booking_flow_type: BookingFlows::Default.to_s) }
  let(:booking) { create(:booking, organisation:) }
  subject(:transition) { booking_flow.transition_to(described_class.to_sym) }

  describe 'transition' do
    it do
      transition
      expect(booking.booking_state).to(be_a(described_class))
      expect(booking.deadline.armed).to be(true)
    end
    it { expect { transition }.to use_mail_template(:unconfirmed_request_notification).and_deliver }
    it { expect { transition }.to change { ActionMailer::Base.deliveries.count }.by(1) }
  end
end
