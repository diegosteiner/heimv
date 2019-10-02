require 'rails_helper'

RSpec.describe RefStrategies::ESR, type: :model do
  subject(:ref_strategy) { described_class.new }

  describe '#checksum' do
    it 'calculates the checksum' do
      expect(ref_strategy.checksum('00000001000014000000000001')).to eq(8)
    end
  end
end
