require 'rails_helper'

RSpec::Matchers.define :have_state do |expected|
  match do |actual|
    actual.state_machine.in_state?(expected)
  end
end

describe Booking, type: :model do
  let(:customer) { create(:customer) }
  let(:home) { create(:home) }
  let(:booking) { build(:booking, customer: customer, home: home) }

  describe 'Occupancy' do
    let(:booking_params) do
      attributes_for(:booking).merge(occupancy_attributes: attributes_for(:occupancy),
                                     customer: customer,
                                     home: home)
    end

    it 'creates all occupancy-related attributes in occupancy' do
      expect(booking).to be_valid
      expect(booking.save).to be true
      expect(booking.occupancy).not_to be_new_record
    end

    it 'creates all occupancy-related attributes in occupancy' do
      new_booking = Booking.create(booking_params)
      expect(new_booking).to be_truthy
      expect(new_booking.occupancy).not_to be_new_record
      expect(new_booking.occupancy.home).to eq(new_booking.home)
    end

    it 'updates all occupancy-related attributes in occupancy' do
      update_booking = create(:booking)
      expect(update_booking.update(booking_params)).to be true
    end
  end

  describe '#state_changed?' do
    let(:booking) { create(:booking, initial_state: :new_request) }
    it { expect { booking.state = :new_request }.not_to(change { booking.state_changed? }) }
    it { expect { booking.state = '' }.not_to(change { booking.state_changed? }) }
    it { expect { booking.state = :provisional_request }.to(change { booking.state_changed? }) }
  end

  describe '#state' do
    context 'with default state' do
      it 'sets initial as default state' do
        expect(booking).to be_valid
        expect(booking).to have_state(:initial)
        expect(booking.save).to be true
        expect(booking.state).to eq('initial')
      end

      it 'will not transition into invalid state' do
        expect { booking.update!(state: :completed) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'will transition into valid state' do
        booking.state = :new_request
        expect(booking).to be_valid
        expect(booking.save).to be true
        expect(booking).to have_state(:new_request)
        expect(booking.state).to eq('new_request')
      end
    end

    context 'with "new_request" state' do
      let(:booking) { create(:booking, initial_state: :new_request) }
      before { allow(booking).to receive_message_chain(:bills, :open, :none?).and_return(true) }

      it 'will transition into valid state' do
        booking.update(state: :cancelled)
        expect(booking).to have_state(:cancelled)
      end
    end
  end
end
