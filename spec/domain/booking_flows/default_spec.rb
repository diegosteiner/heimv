# frozen_string_literal: true

require 'rails_helper'
describe BookingFlows::Default do
  subject(:booking_flow) { described_class.new(booking) }

  let(:home) { create(:home) }
  let(:conflicting) do
    create(:booking, organisation:, home:,
                     begins_at: booking.begins_at, ends_at: booking.ends_at,
                     initial_state: :upcoming).tap(&:occupied!)
  end
  let(:organisation) { create(:organisation, :with_templates) }
  let(:booking) { create(:booking, organisation:, home:, committed_request:) }
  let(:committed_request) { true }

  describe '#transition_to' do
    describe 'to unconfirmed_request' do
      let(:committed_request) { false }

      it do
        is_expected.to transition_to(:unconfirmed_request).from(:initial)
        expect(booking).to be_tentative
        expect(booking).to notify(:unconfirmed_request_notification).to(:tenant)
      end
    end

    describe 'to open_request' do
      let(:committed_request) { false }

      it { is_expected.to transition_to(:open_request).from(:initial) }

      it do
        is_expected.to transition_to(:open_request).from(:unconfirmed_request)
        expect(booking).to notify(:manage_new_booking_notification).to(:administration)
        expect(booking).to notify(:open_request_notification).to(:tenant)
        expect(booking).to be_tentative
      end
    end

    describe 'to waitlisted_request' do
      let(:committed_request) { false }

      before { allow(organisation.booking_state_settings).to receive(:enable_waitlist).and_return(enable_waitlist) }

      context 'with waitlist enabled' do
        let(:enable_waitlist) { true }

        it { is_expected.to transition_to(:waitlisted_request).from(:initial) }

        it do
          is_expected.to transition_to(:waitlisted_request).from(:open_request)
          expect(booking).to notify(:waitlisted_request_notification).to(:tenant)
          expect(booking).to be_tentative
          expect(booking.deadline).not_to be_present
        end
      end

      context 'without waitlist enabled' do
        let(:enable_waitlist) { false }

        it { is_expected.not_to transition_to(:waitlisted_request).from(:initial) }
        it { is_expected.not_to transition_to(:waitlisted_request).from(:open_request) }
      end
    end

    describe 'to provisional_request' do
      let(:committed_request) { false }

      it { is_expected.to transition_to(:provisional_request).from(:initial) }

      it do
        is_expected.to transition_to(:provisional_request).from(:open_request)
        expect(booking).to be_tentative
        expect(booking.deadline).to be_armed
        expect(booking).to notify(:provisional_request_notification).to(:tenant)
      end

      it do
        is_expected.to transition_to(:provisional_request).from(:waitlisted_request)
        expect(booking).to be_tentative
        expect(booking.deadline).to be_armed
        expect(booking).to notify(:provisional_request_notification).to(:tenant)
      end

      context 'with existing booking at the same date' do
        before { conflicting }

        it { is_expected.not_to transition_to(:provisional_request).from(:initial) }
        it { is_expected.not_to transition_to(:provisional_request).from(:open_request) }
        it { is_expected.not_to transition_to(:provisional_request).from(:waitlisted_request) }
      end

      context 'with enable_waitlist' do
        before { conflicting.tentative! }

        it { is_expected.not_to transition_to(:provisional_request).from(:open_request) }
      end

      context 'without enable_provisional_request' do
        before { allow(organisation.booking_state_settings).to receive(:enable_provisional_request).and_return(false) }

        it { is_expected.not_to transition_to(:provisional_request).from(:initial) }
        it { is_expected.not_to transition_to(:provisional_request).from(:open_request) }
        it { is_expected.not_to transition_to(:provisional_request).from(:waitlisted_request) }
        it { is_expected.not_to transition_to(:provisional_request).from(:definitive_request) }
      end
    end

    describe 'to booking_agent_request' do
      let(:committed_request) { false }

      before do
        booking_agent = create(:booking_agent, organisation:)
        booking.build_agent_booking.update(booking_agent_code: booking_agent.code, organisation:)
      end

      it do
        is_expected.to transition_to(:booking_agent_request).from(:open_request)
        expect(booking).to be_tentative
        expect(booking.deadline).to be_armed
        expect(booking).to notify(:booking_agent_request_notification).to(:booking_agent)
      end

      context 'with existing booking at the same date' do
        before { conflicting }

        it { is_expected.not_to transition_to(:booking_agent_request).from(:initial) }
        it { is_expected.not_to transition_to(:booking_agent_request).from(:open_request) }
      end
    end

    describe 'to awaiting_tenant' do
      before do
        booking_agent = create(:booking_agent, organisation:)
        booking.build_agent_booking.update(booking_agent_code: booking_agent.code, organisation:)
      end

      it { is_expected.to transition_to(:awaiting_tenant).from(:initial) }

      it do
        is_expected.to transition_to(:awaiting_tenant).from(:booking_agent_request)
        expect(booking).to be_occupied
        expect(booking.deadline).to be_armed
        expect(booking).to notify(:awaiting_tenant_notification).to(:tenant)
        expect(booking).to notify(:booking_agent_request_accepted_notification).to(:booking_agent)
      end
    end

    describe 'to definitive_request' do
      context 'without committed booking' do
        let(:committed_request) { false }

        it { is_expected.not_to transition_to(:definitive_request).from(:initial) }
        it { is_expected.not_to transition_to(:definitive_request).from(:open_request) }
        it { is_expected.not_to transition_to(:definitive_request).from(:provisional_request) }
        it { is_expected.not_to transition_to(:definitive_request).from(:waitlisted_request) }
        it { is_expected.not_to transition_to(:definitive_request).from(:overdue_request) }
      end

      context 'with committed booking' do
        let(:committed_request) { true }

        it { is_expected.to transition_to(:definitive_request).from(:initial) }
        it { is_expected.to transition_to(:definitive_request).from(:open_request) }

        it do
          is_expected.to transition_to(:definitive_request).from(:overdue_request)
          expect(booking).to be_occupied
          expect(booking.deadline).not_to be_present
          expect(booking).to notify(:definitive_request_notification).to(:tenant)
          expect(booking).to notify(:manage_definitive_request_notification).to(:administration)
        end

        it do
          is_expected.to transition_to(:definitive_request).from(:provisional_request)
          expect(booking).to be_occupied
          expect(booking.deadline).not_to be_present
          expect(booking).to notify(:definitive_request_notification).to(:tenant)
          expect(booking).to notify(:manage_definitive_request_notification).to(:administration)
        end

        it do
          is_expected.to transition_to(:definitive_request).from(:waitlisted_request)
          expect(booking).to be_occupied
          expect(booking).to notify(:definitive_request_notification).to(:tenant)
          expect(booking).to notify(:manage_definitive_request_notification).to(:administration)
        end

        context 'with existing booking at the same date' do
          before { conflicting }

          it { is_expected.not_to transition_to(:definitive_request).from(:provisional_request) }
          it { is_expected.not_to transition_to(:definitive_request).from(:waitlisted_request) }
        end
      end
    end

    describe 'to overdue_request' do
      it { is_expected.to transition_to(:overdue_request).from(:provisional_request) }
      it { is_expected.to transition_to(:overdue_request).from(:booking_agent_request) }
      it { is_expected.to transition_to(:overdue_request).from(:awaiting_tenant) }
      it { is_expected.not_to transition_to(:overdue_request).from(:definitive_request) }

      it do
        is_expected.to transition_to(:overdue_request).from(:provisional_request)
        expect(booking).to notify(:overdue_request_notification).to(:tenant)
      end
    end

    describe 'to cancelled_request' do
      it { is_expected.to transition_to(:cancelled_request).from(:unconfirmed_request) }
      it { is_expected.to transition_to(:cancelled_request).from(:booking_agent_request) }
      it { is_expected.to transition_to(:cancelled_request).from(:waitlisted_request) }
      it { is_expected.to transition_to(:cancelled_request).from(:overdue_request) }
      it { is_expected.not_to transition_to(:cancelled_request).from(:definitive_request) }

      it do
        is_expected.to transition_to(:cancelled_request).from(:provisional_request)
        expect(booking).to be_free
        expect(booking).to be_concluded
        expect(booking.deadline).to be_blank
        expect(booking).to notify(:cancelled_request_notification).to(:tenant)
      end
    end

    describe 'to declined_request' do
      it { is_expected.to transition_to(:declined_request).from(:open_request) }
      it { is_expected.to transition_to(:declined_request).from(:unconfirmed_request) }
      it { is_expected.to transition_to(:declined_request).from(:waitlisted_request) }
      it { is_expected.to transition_to(:declined_request).from(:booking_agent_request) }
      it { is_expected.to transition_to(:declined_request).from(:awaiting_tenant) }
      it { is_expected.to transition_to(:declined_request).from(:overdue_request) }
      it { is_expected.not_to transition_to(:declined_request).from(:definitive_request) }

      it do
        is_expected.to transition_to(:declined_request).from(:provisional_request)
        expect(booking).to be_free
        expect(booking).to be_concluded
        expect(booking.deadline).to be_blank
        expect(booking).to notify(:declined_request_notification).to(:tenant)
      end
    end

    describe 'to cancelation_pending' do
      it { is_expected.to transition_to(:cancelation_pending).from(:awaiting_contract) }
      it { is_expected.to transition_to(:cancelation_pending).from(:upcoming) }
      it { is_expected.to transition_to(:cancelation_pending).from(:upcoming_soon) }
      it { is_expected.to transition_to(:cancelation_pending).from(:past) }
      it { is_expected.to transition_to(:cancelation_pending).from(:payment_due) }
      it { is_expected.to transition_to(:cancelation_pending).from(:payment_overdue) }

      it { is_expected.not_to transition_to(:cancelation_pending).from(:open_request) }
      it { is_expected.not_to transition_to(:cancelation_pending).from(:provisional_request_request) }
      it { is_expected.not_to transition_to(:cancelation_pending).from(:completed) }
      it { is_expected.not_to transition_to(:cancelation_pending).from(:awaiting_tenant) }

      it do
        is_expected.to transition_to(:cancelation_pending).from(:definitive_request)
        expect(booking).to be_free
        expect(booking).not_to be_concluded
        expect(booking.deadline).to be_blank
        expect(booking).to notify(:manage_cancelation_pending_notification).to(:administration)
      end
    end

    describe 'to awaiting_contract' do
      it do
        is_expected.to transition_to(:awaiting_contract).from(:definitive_request)
        expect(booking).to be_occupied
        expect(booking).not_to be_concluded
        expect(booking.deadline).to be_armed
      end
    end

    describe 'to upcoming' do
      it { is_expected.to transition_to(:upcoming).from(:initial) }

      it do
        is_expected.to transition_to(:upcoming).from(:awaiting_contract)
        expect(booking).to be_occupied
        expect(booking).not_to be_concluded
        expect(booking).to notify(:upcoming_notification).to(:tenant)
      end
    end

    describe 'to upcoming_soon' do
      it do
        is_expected.to transition_to(:upcoming_soon).from(:upcoming)
        expect(booking).to be_occupied
        expect(booking).not_to be_concluded
        expect(booking).to notify(:upcoming_soon_notification).to(:tenant)
      end
    end

    describe 'to active' do
      it { is_expected.to transition_to(:active).from(:upcoming_soon) }
    end

    describe 'to past' do
      it do
        is_expected.to transition_to(:past).from(:active)
        expect(booking).to notify(:past_notification).to(:tenant)
      end
    end

    describe 'to payment_due' do
      it { is_expected.to transition_to(:payment_due).from(:past) }

      context 'with invoice' do
        let!(:invoice) { create(:invoice, amount: 1000, booking:, payable_until: 2.weeks.from_now, sent_at: 1.day.ago) }

        it do
          is_expected.to transition_to(:payment_due).from(:past)
          expect(booking.deadline).to be_armed
        end
      end
    end

    describe 'to payment_overdue' do
      it do
        is_expected.to transition_to(:payment_overdue).from(:payment_due)
        expect(booking).not_to be_concluded
        expect(booking.deadline).to be_blank
        expect(booking).to notify(:payment_overdue_notification).to(:tenant)
      end
    end

    describe 'to cancelled' do
      it { is_expected.not_to transition_to(:cancelled).from(:awaiting_contract) }
      it { is_expected.not_to transition_to(:cancelled).from(:upcoming) }
      it { is_expected.not_to transition_to(:cancelled).from(:upcoming_soon) }
      it { is_expected.not_to transition_to(:cancelled).from(:past) }
      it { is_expected.not_to transition_to(:cancelled).from(:payment_due) }
      it { is_expected.not_to transition_to(:cancelled).from(:payment_overdue) }
      it { is_expected.not_to transition_to(:cancelled).from(:open_request) }
      it { is_expected.not_to transition_to(:cancelled).from(:provisional_request_request) }
      it { is_expected.not_to transition_to(:cancelled).from(:completed) }
      it { is_expected.not_to transition_to(:cancelled).from(:awaiting_tenant) }

      it do
        is_expected.to transition_to(:cancelled).from(:cancelation_pending)
        expect(booking).to notify(:cancelled_notification).to(:tenant)
        expect(booking).to be_concluded
        expect(booking.deadline).to be_blank
      end
    end

    describe 'to completed' do
      it { is_expected.to transition_to(:completed).from(:past) }
      it { is_expected.to transition_to(:completed).from(:payment_overdue) }

      it { is_expected.not_to transition_to(:completed).from(:awaiting_contract) }
      it { is_expected.not_to transition_to(:completed).from(:upcoming) }
      it { is_expected.not_to transition_to(:completed).from(:upcoming_soon) }
      it { is_expected.not_to transition_to(:completed).from(:open_request) }
      it { is_expected.not_to transition_to(:completed).from(:provisional_request_request) }
      it { is_expected.not_to transition_to(:completed).from(:awaiting_tenant) }

      it do
        is_expected.to transition_to(:completed).from(:payment_due)
        expect(booking).to notify(:completed_notification).to(:tenant)
        expect(booking).to be_concluded
        expect(booking.deadline).to be_blank
      end
    end
  end
end
