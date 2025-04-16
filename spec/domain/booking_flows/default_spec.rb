# frozen_string_literal: true

require 'rails_helper'
describe BookingFlows::Default do
  let(:home) { create(:home) }
  let(:organisation) { create(:organisation, :with_templates) }
  let(:booking) { create(:booking, organisation:, home:) }
  subject(:booking_flow) { described_class.new(booking) }
  let(:conflicting) do
    create(:booking, organisation:, home:, begins_at: booking.begins_at, ends_at: booking.ends_at,
                     initial_state: :upcoming).tap(&:occupied!)
  end

  describe '#transition_to' do
    describe 'to unconfirmed_request' do
      it { is_expected.to transition_to(:unconfirmed_request).from(:initial) }
    end

    describe 'to open_request' do
      it { is_expected.to transition_to(:open_request).from(:initial) }
      it { is_expected.to transition_to(:open_request).from(:unconfirmed_request) }
    end

    describe 'to waitlisted_request' do
      before { allow(organisation.booking_state_settings).to receive(:enable_waitlist).and_return(enable_waitlist) }

      context 'with waitlist enabled' do
        let(:enable_waitlist) { true }
        it { is_expected.to transition_to(:waitlisted_request).from(:initial) }
        it do
          is_expected.to transition_to(:waitlisted_request).from(:open_request)
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
      it { is_expected.to transition_to(:provisional_request).from(:initial) }
      it do
        is_expected.to transition_to(:provisional_request).from(:open_request)
        expect(booking).to be_tentative
        expect(booking.deadline).to be_armed
      end
      it do
        is_expected.to transition_to(:provisional_request).from(:waitlisted_request)
        expect(booking).to be_tentative
        expect(booking.deadline).to be_armed
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
      before do
        booking_agent = create(:booking_agent, organisation:)
        booking.build_agent_booking.update(booking_agent_code: booking_agent.code, organisation:)
      end

      it do
        is_expected.to transition_to(:booking_agent_request).from(:open_request)
        expect(booking).to be_tentative
        expect(booking.deadline).to be_armed
      end

      context 'with existing booking at the same date' do
        before { conflicting }
        it { is_expected.not_to transition_to(:booking_agent_request).from(:initial) }
        it { is_expected.not_to transition_to(:booking_agent_request).from(:open_request) }
      end
    end

    describe 'to definitive_request' do
      before { allow(booking).to receive(:committed_request).and_return(committed_request) }

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
        end
        it do
          is_expected.to transition_to(:definitive_request).from(:provisional_request)
          expect(booking).to be_occupied
          expect(booking.deadline).not_to be_present
        end
        it do
          is_expected.to transition_to(:definitive_request).from(:waitlisted_request)
          expect(booking).to be_occupied
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
        is_expected.to transition_to(:cancelled_request).from(:provisional_request)
        expect(booking).to be_free
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
      end
    end

    describe 'from definitive_request' do
      it { is_expected.to transition_to(:awaiting_contract).from(:definitive_request) }
      it { is_expected.to transition_to(:cancelation_pending).from(:definitive_request) }
    end

    describe 'from upcoming' do
      it { is_expected.to transition_to(:cancelation_pending).from(:upcoming) }
      it { is_expected.to transition_to(:upcoming_soon).from(:upcoming) }
    end

    describe 'from upcoming_soon' do
      it { is_expected.to transition_to(:cancelation_pending).from(:upcoming_soon) }
      it { is_expected.to transition_to(:active).from(:upcoming_soon) }
    end

    describe 'from past' do
      it { is_expected.to transition_to(:payment_due).from(:past) }
      it { is_expected.not_to transition_to(:awaiting_contract).from(:past) }
    end

    describe 'from awaiting_contract' do
      it { is_expected.to transition_to(:cancelation_pending).from(:awaiting_contract) }
      it { is_expected.not_to transition_to(:awaiting_contract).from(:awaiting_contract) }
    end

    describe 'from payment_due' do
      it { is_expected.not_to transition_to(:payment_due).from(:payment_due) }
    end

    describe 'from payment_overdue' do
      it { is_expected.to transition_to(:cancelation_pending).from(:payment_overdue) }
      it { is_expected.not_to transition_to(:payment_overdue).from(:payment_overdue) }
    end

    describe 'from cancellation_pending' do
      it { is_expected.to transition_to(:cancelled).from(:cancelation_pending) }
    end
  end

  # describe 'guarded transitions' do
  #   skip 'Invoices & Contracts needed' do
  #     let(:invoices) { double('Invoices') }

  #     describe '-->upcoming' do
  #       let(:contracts) { double('Contracts') }

  #       before do
  #         allow(booking).to receive(:contracts).and_return(contracts)
  #         allow(booking).to receive(:invoices).and_return(invoices)
  #       end

  #       context 'with met preconditions' do
  #         before do
  #           allow(contracts).to receive(:any?).and_return(true)
  #           allow(contracts).to receive(:all?).and_return(true)
  #           allow(invoices).to receive_message_chain(:deposits, :all?).and_return(true)
  #         end

  #         it { is_expected.to transition_to(:upcoming).from(:awaiting_contract) }
  #         it { is_expected.to transition_to(:upcoming).from(:overdue) }
  #       end

  #       context 'with unmet preconditions' do
  #         before do
  #           allow(contracts).to receive(:any?).and_return(false)
  #           allow(contracts).to receive(:all?).and_return(false)
  #           allow(invoices).to receive_message_chain(:deposits, :all?).and_return(false)
  #         end

  #         it { is_expected.not_to transition_to(:upcoming).from(:awaiting_contract) }
  #         it { is_expected.not_to transition_to(:upcoming).from(:overdue) }
  #       end
  #     end

  #     describe '-->completed' do
  #       before do
  #         allow(booking).to receive(:invoices).and_return(invoices)
  #       end

  #       context 'with met preconditions' do
  #         before do
  #           allow(invoices).to receive(:any?).and_return(true)
  #           allow(invoices).to receive_message_chain(:open, :none?).and_return(true)
  #         end

  #         it { is_expected.to transition_to(:completed).from(:payment_due) }
  #         it { is_expected.to transition_to(:completed).from(:payment_overdue) }
  #       end

  #       context 'with unmet preconditions' do
  #         before do
  #           allow(invoices).to receive(:any?).and_return(false)
  #           allow(invoices).to receive_message_chain(:open, :none?).and_return(false)
  #         end

  #         it { is_expected.not_to transition_to(:completed).from(:payment_due) }
  #         it { is_expected.not_to transition_to(:completed).from(:payment_overdue) }
  #         it { is_expected.not_to transition_to(:completed).from(:past) }
  #       end
  #     end

  #     describe '-->cancelation_pending' do
  #       it { is_expected.to transition_to(:cancelation_pending).from(:overdue_request) }
  #       it { is_expected.to transition_to(:cancelation_pending).from(:unconfirmed_request) }
  #       it { is_expected.to transition_to(:cancelation_pending).from(:provisional_request) }
  #       it { is_expected.to transition_to(:cancelation_pending).from(:definitive_request) }
  #       it { is_expected.to transition_to(:cancelation_pending).from(:awaiting_contract) }
  #       it { is_expected.to transition_to(:cancelation_pending).from(:overdue) }
  #       it { is_expected.to transition_to(:cancelation_pending).from(:upcoming) }
  #     end

  #     describe '-->cancelled' do
  #       before do
  #         allow(booking).to receive(:invoices).and_return(invoices)
  #       end

  #       context 'with met preconditions' do
  #         before do
  #           allow(invoices).to receive_message_chain(:open, :none?).and_return(true)
  #         end

  #         it { is_expected.to transition_to(:cancelled).from(:cancelation_pending) }
  #       end

  #       context 'with unmet preconditions' do
  #         before do
  #           allow(invoices).to receive_message_chain(:open, :none?).and_return(false)
  #         end

  #         it { is_expected.not_to transition_to(:cancelled).from(:cancelation_pending) }
  #       end
  #     end
  #   end
  # end
end
