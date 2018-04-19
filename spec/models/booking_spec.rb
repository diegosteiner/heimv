require 'rails_helper'

describe Booking, type: :model do
  let(:customer) { create(:customer) }
  let(:home) { create(:home) }
  let(:booking) { build(:booking, customer: customer, home: home) }

  describe 'Customer' do
    context 'with new customer' do
      it 'uses existing customer when email is correct' do
        booking.email = build(:customer).email
        expect(booking.save).to be true
        expect(booking.customer).not_to be_new_record
        expect(booking.customer).to be_a Customer
      end
    end

    context 'with existing customer' do
      let(:existing_customer) { create(:customer) }
      let(:customer) { nil }

      it 'uses existing customer when email is correct' do
        booking.email = existing_customer.email
        expect(booking.save).to be true
        expect(booking.customer_id).to eq(existing_customer.id)
      end
    end
  end

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
end
