require 'rails_helper'

RSpec.describe InvoiceParts::Factory, type: :model do
  let(:builder) { described_class.new }

  describe '#suggest' do
    let(:home) { create(:home) }
    let(:booking) { create(:booking, initial_state: :confirmed, home: home) }
    let(:invoice) { create(:invoice, booking: booking) }
    let!(:usages) { create_list(:usage, 3, booking: booking) }
    let(:invoiced_usage) { create(:usage, booking: booking) }
    let(:existing_invoice_part) { create(:invoice_part, invoice: invoice, usage: invoiced_usage) }

    subject { builder.suggest(invoice) }

    it do
      is_expected.to(be_all { |actual| actual.is_a?(InvoiceParts::Add) })
      is_expected.to(be_all { |actual| actual == existing_invoice_part || actual.new_record? })

      usage_ids = subject.map(&:usage_id)
      expect(usage_ids).to include(*usages.map(&:id))
      expect(usage_ids).not_to include(existing_invoice_part.usage_id)
    end
  end
end
