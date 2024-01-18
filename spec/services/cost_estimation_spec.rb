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

  describe '#invoiced' do
    let!(:invoices) { create_list(:invoice, 2, booking:, amount: 500) }
    let!(:deposits) { create_list(:deposit, 2, booking:, amount: 250) }
    let!(:payments) { invoices.map { |invoice| create(:payment, invoice:, amount: 100) } }

    it 'returns sums for invoices' do
      expect(estimation.invoiced).to eq(1000)
      expect(estimation.invoiced_deposits).to eq(500)
      expect(estimation.paid).to eq(200)
    end
  end
end
