# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CostEstimation, type: :model do
  let(:organisation) { create(:organisation) }
  let(:booking) { create(:booking, organisation:) }
  let(:fixcosts) { 100 }
  let(:estimation) { described_class.new(booking, fixcosts:) }

  before do
    create_list(:booking, 10, initial_state: :completed).each do |booking|
      create(:invoice, booking:)
    end
  end

  describe '#total' do
    it 'calculates the totals' do
      expect(estimation.projection).to be > 0
    end
  end
end
