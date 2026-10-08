# frozen_string_literal: true

require 'rails_helper'
describe BookingFlows::Default do
  subject(:booking_flow) { described_class.new(booking) }

  let(:home) { create(:home, organisation:) }
  let(:begins_at) { 2.months.from_now }
  let(:ends_at) { begins_at + 1.week }
  let(:conflicting_booking) do
    build(:booking, organisation:, home:, begins_at:, ends_at:,
                    initial_state: :upcoming, occupancy_status: :occupied, remarks: 'conflicting').tap do |booking|
      booking.save!(validate: false)
    end
  end
  let(:organisation) { create(:organisation, :with_templates) }
  let(:enable_waitlist) { false }

  def prepare_booking(**args)
    create(:booking, organisation:, home:, begins_at:, ends_at:, committed_request: false, remarks: 'subject', **args)
  end

  before { allow(organisation.booking_state_settings).to receive(:enable_waitlist).and_return(enable_waitlist) }

  describe '#transition_to' do
    # Intake and reopen paths
    describe 'to unconfirmed_request' do
      context 'with booking from initial state' do
        let(:booking) { prepare_booking(initial_state: :initial) }

        it do
          expect(booking_flow).to transition_to(:unconfirmed_request)
          expect(booking).to be_status_pending
          expect(booking).to notify(:unconfirmed_request_notification).to(:tenant)
        end
      end
    end

    describe 'to open_request' do
      context 'with booking from initial state' do
        let(:booking) { prepare_booking(initial_state: :initial) }

        it do
          expect(booking_flow).to transition_to(:open_request)
        end
      end

      context 'with booking from unconfirmed_request state' do
        let(:booking) { prepare_booking(initial_state: :unconfirmed_request) }

        it do
          expect(booking_flow).to transition_to(:open_request)
          expect(booking).to notify(:manage_new_booking_notification).to(:administration)
          expect(booking).to notify(:open_request_notification).to(:tenant)
          expect(booking).to be_status_pending
        end
      end

      context 'with booking from cancelled_request state' do
        let(:booking) { prepare_booking(initial_state: :cancelled_request) }

        it do
          expect(booking_flow).to transition_to(:open_request)
        end
      end

      context 'with booking from declined_request state' do
        let(:booking) { prepare_booking(initial_state: :declined_request) }

        it do
          expect(booking_flow).to transition_to(:open_request)
        end
      end
    end

    # Waitlist behavior
    describe 'waitlist: to waitlisted_request' do
      context 'with waitlist enabled' do
        let(:enable_waitlist) { true }

        context 'with default booking' do
          let(:booking) { prepare_booking }

          it do
            expect(booking_flow).to transition_to(:waitlisted_request)
          end
        end

        context 'with booking from open_request state' do
          let(:booking) { prepare_booking(initial_state: :open_request) }

          it do
            expect(booking_flow).to transition_to(:waitlisted_request)
            expect(booking).to notify(:waitlisted_request_notification).to(:tenant)
            expect(booking).to be_status_pending
            expect(booking.deadline&.armed?).to be_falsy
          end
        end
      end

      context 'without waitlist enabled' do
        let(:enable_waitlist) { false }

        context 'with default booking' do
          let(:booking) { prepare_booking }

          it do
            expect(booking_flow).not_to transition_to(:waitlisted_request)
          end
        end

        context 'with booking from open_request state' do
          let(:booking) { prepare_booking(initial_state: :open_request) }

          it do
            expect(booking_flow).not_to transition_to(:waitlisted_request)
          end
        end
      end
    end

    describe 'waitlist/commitment: to provisional_request' do
      context 'with default booking' do
        let(:booking) { prepare_booking }

        it do
          expect(booking_flow).to transition_to(:provisional_request)
        end
      end

      context 'with booking from open_request state' do
        let(:booking) { prepare_booking(initial_state: :open_request) }

        it do
          expect(booking_flow).to transition_to(:provisional_request)
          expect(booking).to be_status_tentative
          expect(booking.deadline).to be_armed
          expect(booking).to notify(:provisional_request_notification).to(:tenant)
        end
      end

      context 'with booking from waitlisted_request state' do
        let(:booking) { prepare_booking(initial_state: :waitlisted_request) }

        it do
          expect(booking_flow).to transition_to(:provisional_request)
          expect(booking).to be_status_tentative
          expect(booking.deadline).to be_armed
          expect(booking).to notify(:provisional_request_notification).to(:tenant)
        end
      end

      context 'with booking from definitive_request and occupied' do
        let(:booking) do
          prepare_booking(initial_state: :definitive_request, occupancy_status: :occupied, committed_request: true)
        end

        it do
          expect(booking_flow).to transition_to(:provisional_request)
          expect(booking).to be_status_tentative
          expect(booking.deadline).to be_armed
          expect(booking.committed_request).to be_falsy
        end
      end

      context 'when waitlist is enabled and booking conflicts' do
        let(:enable_waitlist) { true }

        before { conflicting_booking }

        context 'with booking from open_request state' do
          let(:booking) { prepare_booking(initial_state: :open_request) }

          it do
            expect(booking_flow).not_to transition_to(:provisional_request)
          end
        end
      end

      context 'when provisional requests are disabled' do
        before { allow(organisation.booking_state_settings).to receive(:enable_provisional_request).and_return(false) }

        context 'with default booking' do
          let(:booking) { prepare_booking }

          it do
            expect(booking_flow).not_to transition_to(:provisional_request)
          end
        end

        context 'with booking from open_request state' do
          let(:booking) { prepare_booking(initial_state: :open_request) }

          it do
            expect(booking_flow).not_to transition_to(:provisional_request)
          end
        end

        context 'with booking from waitlisted_request state' do
          let(:booking) { prepare_booking(initial_state: :waitlisted_request) }

          it do
            expect(booking_flow).not_to transition_to(:provisional_request)
          end
        end

        context 'with booking from definitive_request and occupied' do
          let(:booking) { prepare_booking(initial_state: :definitive_request, occupancy_status: :occupied) }

          it do
            expect(booking_flow).not_to transition_to(:provisional_request)
          end
        end
      end
    end

    # Booking-agent behavior
    describe 'booking-agent: to booking_agent_request' do
      before do
        booking_agent = create(:booking_agent, organisation:)
        booking.build_agent_booking.update(booking_agent_code: booking_agent.code, organisation:)
      end

      context 'with booking from open_request state' do
        let(:booking) { prepare_booking(initial_state: :open_request) }

        it do
          expect(booking_flow).to transition_to(:booking_agent_request)
          expect(booking).to be_status_tentative
          expect(booking.deadline).to be_armed
          expect(booking).to notify(:booking_agent_request_notification).to(:booking_agent)
        end
      end

      context 'without agent booking on booking' do
        let(:booking) { prepare_booking(initial_state: :open_request) }

        before do
          booking.agent_booking&.destroy!
          booking.reload
        end

        it do
          expect(booking_flow).not_to transition_to(:booking_agent_request)
        end
      end

      context 'with existing booking at the same date' do
        before { conflicting_booking }

        context 'with default booking' do
          let(:booking) { prepare_booking }

          it do
            expect(booking_flow).not_to transition_to(:booking_agent_request)
          end
        end

        context 'with booking from open_request state' do
          let(:booking) { prepare_booking(initial_state: :open_request) }

          it do
            expect(booking_flow).not_to transition_to(:booking_agent_request)
          end
        end
      end
    end

    describe 'booking-agent: to awaiting_tenant' do
      before do
        booking_agent = create(:booking_agent, organisation:)
        booking.build_agent_booking.update(booking_agent_code: booking_agent.code, organisation:)
      end

      context 'with default booking' do
        let(:booking) { prepare_booking }

        it do
          expect(booking_flow).to transition_to(:awaiting_tenant)
        end
      end

      context 'with booking from booking_agent_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :booking_agent_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:awaiting_tenant)
          expect(booking).to be_status_occupied
          expect(booking.deadline).to be_armed
          expect(booking).to notify(:awaiting_tenant_notification).to(:tenant)
          expect(booking).to notify(:booking_agent_request_accepted_notification).to(:booking_agent)
        end
      end

      context 'with booking from overdue_request and tentative' do
        let(:booking) do
          prepare_booking(initial_state: :overdue_request, occupancy_status: :tentative, committed_request: false)
        end

        it do
          expect(booking_flow).to transition_to(:awaiting_tenant)
        end
      end
    end

    # Committed-request behavior
    describe 'committed-request: to definitive_request' do
      context 'without committed request' do
        context 'with default booking' do
          let(:booking) { prepare_booking }

          it do
            expect(booking_flow).not_to transition_to(:definitive_request)
          end
        end

        context 'with booking from open_request state' do
          let(:booking) { prepare_booking(initial_state: :open_request) }

          it do
            expect(booking_flow).not_to transition_to(:definitive_request)
          end
        end

        context 'with booking from provisional_request and tentative' do
          let(:booking) { prepare_booking(initial_state: :provisional_request, occupancy_status: :tentative) }

          it do
            expect(booking_flow).not_to transition_to(:definitive_request)
          end
        end

        context 'with booking from waitlisted_request state' do
          let(:booking) { prepare_booking(initial_state: :waitlisted_request) }

          it do
            expect(booking_flow).not_to transition_to(:definitive_request)
          end
        end

        context 'with booking from overdue_request and tentative' do
          let(:booking) { prepare_booking(initial_state: :overdue_request, occupancy_status: :tentative) }

          it do
            expect(booking_flow).not_to transition_to(:definitive_request)
          end
        end
      end

      context 'with committed request' do
        context 'with committed default booking' do
          let(:booking) { prepare_booking(committed_request: true) }

          it do
            expect(booking_flow).to transition_to(:definitive_request)
          end
        end

        context 'with booking from open_request and committed' do
          let(:booking) { prepare_booking(initial_state: :open_request, committed_request: true) }

          it do
            expect(booking_flow).to transition_to(:definitive_request)
          end
        end

        context 'with booking from overdue_request tentative and committed' do
          let(:booking) do
            prepare_booking(initial_state: :overdue_request, occupancy_status: :tentative,
                            committed_request: true)
          end

          it do
            expect(booking_flow).to transition_to(:definitive_request)
            expect(booking).to be_status_occupied
            expect(booking.deadline).not_to be_present
            expect(booking).to notify(:definitive_request_notification).to(:tenant)
            expect(booking).to notify(:manage_definitive_request_notification).to(:administration)
          end
        end

        context 'with booking from provisional_request and tentative' do
          let(:booking) do
            prepare_booking(initial_state: :provisional_request, occupancy_status: :tentative, committed_request: true)
          end

          it do
            expect(booking_flow).to transition_to(:definitive_request)
            expect(booking).to be_status_occupied
            expect(booking.deadline).not_to be_present
            expect(booking).to notify(:definitive_request_notification).to(:tenant)
            expect(booking).to notify(:manage_definitive_request_notification).to(:administration)
          end
        end

        context 'with booking from waitlisted_request state' do
          let(:booking) { prepare_booking(initial_state: :waitlisted_request, committed_request: true) }

          it do
            expect(booking_flow).to transition_to(:definitive_request)
            expect(booking).to be_status_occupied
            expect(booking).to notify(:definitive_request_notification).to(:tenant)
            expect(booking).to notify(:manage_definitive_request_notification).to(:administration)
          end
        end

        context 'with existing booking at the same date' do
          before { conflicting_booking }

          context 'with booking from provisional_request and tentative' do
            let(:booking) do
              build(:booking, organisation:, home:, begins_at:, ends_at:, remarks: 'subject',
                              initial_state: :provisional_request, occupancy_status: :tentative,
                              committed_request: true).tap { |candidate| candidate.save!(validate: false) }
            end

            it do
              expect(booking_flow).not_to transition_to(:definitive_request)
            end
          end

          context 'with booking from waitlisted_request state' do
            let(:booking) { prepare_booking(initial_state: :waitlisted_request) }

            it do
              expect(booking_flow).not_to transition_to(:definitive_request)
            end
          end
        end
      end
    end

    # Post-request lifecycle
    describe 'to overdue_request' do
      context 'with booking from provisional_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :provisional_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:overdue_request)
        end
      end

      context 'with booking from booking_agent_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :booking_agent_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:overdue_request)
        end
      end

      context 'with booking from awaiting_tenant and tentative' do
        let(:booking) { prepare_booking(initial_state: :awaiting_tenant, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:overdue_request)
        end
      end

      context 'with booking from definitive_request and occupied' do
        let(:booking) { prepare_booking(initial_state: :definitive_request, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:overdue_request)
        end
      end

      context 'with booking from provisional_request and tentative for notification' do
        let(:booking) { prepare_booking(initial_state: :provisional_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:overdue_request)
          expect(booking).to notify(:overdue_request_notification).to(:tenant)
        end
      end
    end

    describe 'to cancelled_request' do
      context 'with booking from unconfirmed_request state' do
        let(:booking) { prepare_booking(initial_state: :unconfirmed_request) }

        it do
          expect(booking_flow).to transition_to(:cancelled_request)
        end
      end

      context 'with booking from booking_agent_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :booking_agent_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:cancelled_request)
        end
      end

      context 'with booking from waitlisted_request state' do
        let(:booking) { prepare_booking(initial_state: :waitlisted_request) }

        it do
          expect(booking_flow).to transition_to(:cancelled_request)
        end
      end

      context 'with booking from overdue_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :overdue_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:cancelled_request)
        end
      end

      context 'with booking from definitive_request and occupied' do
        let(:booking) { prepare_booking(initial_state: :definitive_request, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled_request)
        end
      end

      context 'with booking from provisional_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :provisional_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:cancelled_request)
          expect(booking).to be_status_void
          expect(booking).to be_concluded
          expect(booking.deadline).to be_blank
          expect(booking).to notify(:cancelled_request_notification).to(:tenant)
        end
      end
    end

    describe 'to declined_request' do
      context 'with booking from open_request state' do
        let(:booking) { prepare_booking(initial_state: :open_request) }

        it do
          expect(booking_flow).to transition_to(:declined_request)
        end
      end

      context 'with booking from unconfirmed_request state' do
        let(:booking) { prepare_booking(initial_state: :unconfirmed_request) }

        it do
          expect(booking_flow).to transition_to(:declined_request)
        end
      end

      context 'with booking from waitlisted_request state' do
        let(:booking) { prepare_booking(initial_state: :waitlisted_request) }

        it do
          expect(booking_flow).to transition_to(:declined_request)
        end
      end

      context 'with booking from booking_agent_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :booking_agent_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:declined_request)
        end
      end

      context 'with booking from awaiting_tenant and tentative' do
        let(:booking) { prepare_booking(initial_state: :awaiting_tenant, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:declined_request)
        end
      end

      context 'with booking from overdue_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :overdue_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:declined_request)
        end
      end

      context 'with booking from definitive_request and occupied' do
        let(:booking) { prepare_booking(initial_state: :definitive_request, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:declined_request)
        end
      end

      context 'with booking from provisional_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :provisional_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:declined_request)
          expect(booking).to be_status_void
          expect(booking).to be_concluded
          expect(booking.deadline).to be_blank
          expect(booking).to notify(:declined_request_notification).to(:tenant)
        end
      end
    end

    # Occupancy lifecycle and closure paths
    describe 'to cancelation_pending' do
      context 'with booking from awaiting_contract and occupied' do
        let(:booking) { prepare_booking(initial_state: :awaiting_contract, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from upcoming and occupied' do
        let(:booking) { prepare_booking(initial_state: :upcoming, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from upcoming_soon and occupied' do
        let(:booking) { prepare_booking(initial_state: :upcoming_soon, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from past and occupied' do
        let(:booking) { prepare_booking(initial_state: :past, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from payment_due and occupied' do
        let(:booking) { prepare_booking(initial_state: :payment_due, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from payment_overdue and occupied' do
        let(:booking) { prepare_booking(initial_state: :payment_overdue, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from open_request state' do
        let(:booking) { prepare_booking(initial_state: :open_request) }

        it do
          expect(booking_flow).not_to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from provisional_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :provisional_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).not_to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from completed state' do
        let(:booking) { prepare_booking(initial_state: :completed) }

        it do
          expect(booking_flow).not_to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from awaiting_tenant and tentative' do
        let(:booking) { prepare_booking(initial_state: :awaiting_tenant, occupancy_status: :tentative) }

        it do
          expect(booking_flow).not_to transition_to(:cancelation_pending)
        end
      end

      context 'with booking from definitive_request and occupied' do
        let(:booking) { prepare_booking(initial_state: :definitive_request, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:cancelation_pending)
          expect(booking).to be_status_void
          expect(booking).not_to be_concluded
          expect(booking.deadline).to be_blank
          expect(booking).to notify(:manage_cancelation_pending_notification).to(:administration)
        end
      end

      context 'with booking from overdue and occupied' do
        let(:booking) { prepare_booking(initial_state: :overdue, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:cancelation_pending)
        end
      end
    end

    describe 'to awaiting_contract' do
      context 'with booking from definitive_request and occupied' do
        let(:booking) { prepare_booking(initial_state: :definitive_request, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:awaiting_contract)
          expect(booking).to be_status_occupied
          expect(booking).not_to be_concluded
          expect(booking.deadline).to be_armed
        end
      end
    end

    describe 'to overdue' do
      context 'with booking from awaiting_contract and occupied' do
        let(:booking) { prepare_booking(initial_state: :awaiting_contract, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:overdue)
        end
      end
    end

    describe 'to upcoming' do
      context 'with default booking' do
        let(:booking) { prepare_booking }

        it do
          expect(booking_flow).to transition_to(:upcoming)
        end
      end

      context 'with booking from awaiting_contract and occupied' do
        let(:booking) { prepare_booking(initial_state: :awaiting_contract, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:upcoming)
          expect(booking).to be_status_occupied
          expect(booking).not_to be_concluded
          expect(booking).to notify(:upcoming_notification).to(:tenant)
        end
      end

      context 'with booking from definitive_request and occupied' do
        let(:booking) { prepare_booking(initial_state: :definitive_request, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:upcoming)
        end
      end

      context 'with booking from open_request state' do
        let(:booking) { prepare_booking(initial_state: :open_request) }

        it do
          expect(booking_flow).to transition_to(:upcoming)
        end
      end

      context 'with booking from waitlisted_request state' do
        let(:booking) { prepare_booking(initial_state: :waitlisted_request) }

        it do
          expect(booking_flow).to transition_to(:upcoming)
        end
      end

      context 'with booking from booking_agent_request state' do
        let(:booking) { prepare_booking(initial_state: :booking_agent_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).to transition_to(:upcoming)
        end
      end

      context 'with booking from overdue state' do
        let(:booking) { prepare_booking(initial_state: :overdue, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:upcoming)
        end
      end
    end

    describe 'to upcoming_soon' do
      context 'with booking from upcoming and occupied' do
        let(:booking) { prepare_booking(initial_state: :upcoming, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:upcoming_soon)
          expect(booking).to be_status_occupied
          expect(booking).not_to be_concluded
          expect(booking).to notify(:upcoming_soon_notification).to(:tenant)
        end
      end
    end

    describe 'to active' do
      context 'with booking from upcoming_soon and occupied' do
        let(:booking) { prepare_booking(initial_state: :upcoming_soon, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:active)
        end
      end
    end

    describe 'to past' do
      context 'with booking from active state' do
        let(:booking) { prepare_booking(initial_state: :active) }

        it do
          expect(booking_flow).to transition_to(:past)
          expect(booking).to notify(:past_notification).to(:tenant)
        end
      end
    end

    describe 'to payment_due' do
      context 'with booking from past and occupied' do
        let(:booking) { prepare_booking(initial_state: :past, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:payment_due)
        end
      end

      context 'with invoice' do
        let(:booking) { prepare_booking(initial_state: :past, occupancy_status: :occupied) }

        context 'with booking from past and occupied' do
          it do
            expect(booking_flow).to be_can_transition_to(:payment_due)
            create(:invoice, amount: 1000, booking:, payable_until: 2.weeks.from_now, sent_at: 1.day.ago)
            expect(booking.deadline).to be_armed
          end
        end
      end
    end

    describe 'to payment_overdue' do
      context 'with booking from payment_due and occupied' do
        let(:booking) { prepare_booking(initial_state: :payment_due, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:payment_overdue)
          expect(booking).not_to be_concluded
          expect(booking.deadline).to be_blank
          expect(booking).to notify(:payment_overdue_notification).to(:tenant)
        end
      end
    end

    # Terminal transitions
    describe 'to cancelled' do
      context 'with booking from awaiting_contract and occupied' do
        let(:booking) { prepare_booking(initial_state: :awaiting_contract, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from upcoming and occupied' do
        let(:booking) { prepare_booking(initial_state: :upcoming, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from upcoming_soon and occupied' do
        let(:booking) { prepare_booking(initial_state: :upcoming_soon, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from past and occupied' do
        let(:booking) { prepare_booking(initial_state: :past, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from payment_due and occupied' do
        let(:booking) { prepare_booking(initial_state: :payment_due, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from payment_overdue and occupied' do
        let(:booking) { prepare_booking(initial_state: :payment_overdue, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from open_request state' do
        let(:booking) { prepare_booking(initial_state: :open_request) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from provisional_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :provisional_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from completed state' do
        let(:booking) { prepare_booking(initial_state: :completed) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from awaiting_tenant and tentative' do
        let(:booking) { prepare_booking(initial_state: :awaiting_tenant, occupancy_status: :tentative) }

        it do
          expect(booking_flow).not_to transition_to(:cancelled)
        end
      end

      context 'with booking from cancelation_pending state' do
        let(:booking) { prepare_booking(initial_state: :cancelation_pending) }

        it do
          expect(booking_flow).to transition_to(:cancelled)
          expect(booking).to notify(:cancelled_notification).to(:tenant)
          expect(booking).to be_concluded
          expect(booking.deadline).to be_blank
        end
      end
    end

    describe 'to completed' do
      context 'with booking from past and occupied' do
        let(:booking) { prepare_booking(initial_state: :past, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:completed)
        end
      end

      context 'with booking from payment_overdue and occupied' do
        let(:booking) { prepare_booking(initial_state: :payment_overdue, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:completed)
        end
      end

      context 'with booking from awaiting_contract and occupied' do
        let(:booking) { prepare_booking(initial_state: :awaiting_contract, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:completed)
        end
      end

      context 'with booking from upcoming and occupied' do
        let(:booking) { prepare_booking(initial_state: :upcoming, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:completed)
        end
      end

      context 'with booking from upcoming_soon and occupied' do
        let(:booking) { prepare_booking(initial_state: :upcoming_soon, occupancy_status: :occupied) }

        it do
          expect(booking_flow).not_to transition_to(:completed)
        end
      end

      context 'with booking from open_request state' do
        let(:booking) { prepare_booking(initial_state: :open_request) }

        it do
          expect(booking_flow).not_to transition_to(:completed)
        end
      end

      context 'with booking from provisional_request and tentative' do
        let(:booking) { prepare_booking(initial_state: :provisional_request, occupancy_status: :tentative) }

        it do
          expect(booking_flow).not_to transition_to(:completed)
        end
      end

      context 'with booking from awaiting_tenant and tentative' do
        let(:booking) { prepare_booking(initial_state: :awaiting_tenant, occupancy_status: :tentative) }

        it do
          expect(booking_flow).not_to transition_to(:completed)
        end
      end

      context 'with booking from payment_due and occupied' do
        let(:booking) { prepare_booking(initial_state: :payment_due, occupancy_status: :occupied) }

        it do
          expect(booking_flow).to transition_to(:completed)
          expect(booking).to notify(:completed_notification).to(:tenant)
          expect(booking).to be_concluded
          expect(booking.deadline).to be_blank
        end
      end
    end
  end
end
