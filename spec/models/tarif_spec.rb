require 'rails_helper'

RSpec.describe Tarif, type: :model do
  let(:home) { create(:home) }

  describe 'scope "for_home"' do
    let!(:expected) { create_list(:tarif, 3, home: home) }
    let!(:unexpected) { create_list(:tarif, 2) }
    subject { described_class.of_home(home) }

    it do
      is_expected.to include(*expected)
      is_expected.not_to include(*unexpected)
    end
  end

  describe 'scope "for_booking"' do
    let(:booking) { create(:booking, home: home) }
    let(:transient_tarifs) { create_list(:tarif, 2, home: home, transient: true) }
    let(:booking_tarifs) { create_list(:tarif, 2, home: home, booking: booking, transient: true) }

    let!(:expected) { [transient_tarifs.to_a, booking_tarifs.to_a].flatten }
    let!(:unexpected) { create_list(:tarif, 2, home: home, transient: false) }

    subject { described_class.of_booking(booking) }

    it do
      is_expected.to include(*expected)
      is_expected.not_to include(*unexpected)
    end
  end
end
