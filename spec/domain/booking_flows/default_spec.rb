# frozen_string_literal: true

require 'rails_helper'
describe BookingFlows::Default do
  let(:home) { create(:home) }
  let(:booking) { create(:booking, organisation: home.organisation, home:) }
  subject(:booking_flow) { described_class.new(booking) }

  describe 'allowed transitions' do
    describe 'initial-->' do
      it { is_expected.to transition_to(:unconfirmed_request) }
      it { is_expected.to transition_to(:provisional_request) }
      it { is_expected.to transition_to(:definitive_request) }
      it { is_expected.to transition_to(:unconfirmed_request) }
      it { is_expected.to transition_to(:definitive_request) }
      it { is_expected.to transition_to(:provisional_request) }

      it 'sends email-confirmation' do
        is_expected.to transition_to(:unconfirmed_request)
      end
    end

    describe 'unconfirmed_request-->' do
      it { is_expected.to transition_to(:open_request).from(:unconfirmed_request) }
      it { is_expected.to transition_to(:cancelled_request).from(:unconfirmed_request) }
      it { is_expected.to transition_to(:declined_request).from(:unconfirmed_request) }
    end

    describe 'open_request-->' do
      it { is_expected.to transition_to(:provisional_request).from(:open_request) }
      it { is_expected.to transition_to(:definitive_request).from(:open_request) }
      it { is_expected.to transition_to(:cancelled_request).from(:open_request) }
      it { is_expected.to transition_to(:declined_request).from(:open_request) }
    end

    describe 'overdue_request-->' do
      it { is_expected.to transition_to(:definitive_request).from(:overdue_request) }
      it { is_expected.to transition_to(:cancelled_request).from(:overdue_request) }
      it { is_expected.to transition_to(:declined_request).from(:overdue_request) }
    end

    describe 'provisional_request-->' do
      it { is_expected.to transition_to(:overdue_request).from(:provisional_request) }
      it { is_expected.to transition_to(:definitive_request).from(:provisional_request) }
      it { is_expected.to transition_to(:cancelled_request).from(:provisional_request) }
      it { is_expected.to transition_to(:declined_request).from(:provisional_request) }
    end

    describe 'definitive_request-->' do
      it { is_expected.to transition_to(:awaiting_contract).from(:definitive_request) }
      it { is_expected.to transition_to(:cancelation_pending).from(:definitive_request) }
    end

    describe 'upcoming-->' do
      it { is_expected.to transition_to(:cancelation_pending).from(:upcoming) }
      it { is_expected.to transition_to(:upcoming_soon).from(:upcoming) }
    end

    describe 'upcoming_soon-->' do
      it { is_expected.to transition_to(:cancelation_pending).from(:upcoming_soon) }
      it { is_expected.to transition_to(:active).from(:upcoming_soon) }
    end

    describe 'past-->' do
      it { is_expected.to transition_to(:payment_due).from(:past) }
      it { is_expected.not_to transition_to(:awaiting_contract).from(:past) }
    end

    describe 'awaiting_contract-->' do
      it { is_expected.to transition_to(:cancelation_pending).from(:awaiting_contract) }
      it { is_expected.not_to transition_to(:awaiting_contract).from(:awaiting_contract) }
    end

    describe 'payment_overdue-->' do
      it { is_expected.to transition_to(:cancelation_pending).from(:payment_overdue) }
    end

    describe 'cancellation_pending-->' do
      it { is_expected.to transition_to(:cancelled).from(:cancelation_pending) }
    end
  end

  describe 'prohibited transitions' do
    it { is_expected.not_to transition_to(:payment_due).from(:payment_due) }
    it { is_expected.not_to transition_to(:payment_overdue).from(:payment_overdue) }
  end

  describe 'guarded transitions' do
    skip 'Invoices & Contracts needed' do
      let(:invoices) { double('Invoices') }

      describe '-->upcoming' do
        let(:contracts) { double('Contracts') }

        before do
          allow(booking).to receive(:contracts).and_return(contracts)
          allow(booking).to receive(:invoices).and_return(invoices)
        end

        context 'with met preconditions' do
          before do
            allow(contracts).to receive(:any?).and_return(true)
            allow(contracts).to receive(:all?).and_return(true)
            allow(invoices).to receive_message_chain(:deposits, :all?).and_return(true)
          end

          it { is_expected.to transition_to(:upcoming).from(:awaiting_contract) }
          it { is_expected.to transition_to(:upcoming).from(:overdue) }
        end

        context 'with unmet preconditions' do
          before do
            allow(contracts).to receive(:any?).and_return(false)
            allow(contracts).to receive(:all?).and_return(false)
            allow(invoices).to receive_message_chain(:deposits, :all?).and_return(false)
          end

          it { is_expected.not_to transition_to(:upcoming).from(:awaiting_contract) }
          it { is_expected.not_to transition_to(:upcoming).from(:overdue) }
        end
      end

      describe '-->completed' do
        before do
          allow(booking).to receive(:invoices).and_return(invoices)
        end

        context 'with met preconditions' do
          before do
            allow(invoices).to receive(:any?).and_return(true)
            allow(invoices).to receive_message_chain(:open, :none?).and_return(true)
          end

          it { is_expected.to transition_to(:completed).from(:payment_due) }
          it { is_expected.to transition_to(:completed).from(:payment_overdue) }
        end

        context 'with unmet preconditions' do
          before do
            allow(invoices).to receive(:any?).and_return(false)
            allow(invoices).to receive_message_chain(:open, :none?).and_return(false)
          end

          it { is_expected.not_to transition_to(:completed).from(:payment_due) }
          it { is_expected.not_to transition_to(:completed).from(:payment_overdue) }
          it { is_expected.not_to transition_to(:completed).from(:past) }
        end
      end

      describe '-->cancelation_pending' do
        it { is_expected.to transition_to(:cancelation_pending).from(:overdue_request) }
        it { is_expected.to transition_to(:cancelation_pending).from(:unconfirmed_request) }
        it { is_expected.to transition_to(:cancelation_pending).from(:provisional_request) }
        it { is_expected.to transition_to(:cancelation_pending).from(:definitive_request) }
        it { is_expected.to transition_to(:cancelation_pending).from(:awaiting_contract) }
        it { is_expected.to transition_to(:cancelation_pending).from(:overdue) }
        it { is_expected.to transition_to(:cancelation_pending).from(:upcoming) }
      end

      describe '-->cancelled' do
        before do
          allow(booking).to receive(:invoices).and_return(invoices)
        end

        context 'with met preconditions' do
          before do
            allow(invoices).to receive_message_chain(:open, :none?).and_return(true)
          end

          it { is_expected.to transition_to(:cancelled).from(:cancelation_pending) }
        end

        context 'with unmet preconditions' do
          before do
            allow(invoices).to receive_message_chain(:open, :none?).and_return(false)
          end

          it { is_expected.not_to transition_to(:cancelled).from(:cancelation_pending) }
        end
      end
    end
  end
end
