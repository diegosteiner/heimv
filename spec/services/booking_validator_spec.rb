
require 'rails_helper'

describe BookingValidator::PublicCreate, type: :service  do
  subject(:validator) { described_class.new }
  let(:booking) { build(:booking) }

  it do
    booking.assign_attributes(occupiables: [])
    validator.validate(booking)
    binding.pry
    expect(booking).not_to be_valid
    # expect(other_booking).to be_valid
    booking.assign_attributes(occupiables: [home])
    expect(booking).to be_valid
  end
end
