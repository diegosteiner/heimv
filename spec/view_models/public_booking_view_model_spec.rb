require 'rails_helper'

RSpec.describe PublicBookingViewModel, type: :model do
  let(:booking) { build_stubbed(:booking) }

  describe '#booking' do
    subject { vm.booking }
    let(:vm) { described_class.new(booking) }

    it { is_expected.to eq(booking) }
  end
end
