require 'rails_helper'

RSpec.describe BookingMailerViewModel, type: :model do
  let(:booking) { build_stubbed(:booking) }

  describe '#to' do
    subject { vm.to }
    let(:to) { 'email@hv.dev' }
    let(:vm) { described_class.new(booking, to) }

    it { is_expected.to eq(to) }
  end

  describe '#booking' do
    subject { vm.booking }
    let(:vm) { described_class.new(booking) }

    it { is_expected.to eq(booking) }
  end
end
