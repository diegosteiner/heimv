require 'rails_helper'

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

  describe '#public_id' do
    it 'generates a public_id when created' do
      expect(booking.save).to be true
      booking.reload
      expect(booking.public_id).not_to be_nil
    end
  end
end
