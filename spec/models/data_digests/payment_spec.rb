# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                      :bigint           not null, primary key
#  data                    :jsonb
#  period_from             :datetime
#  period_to               :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  data_digest_template_id :bigint           not null
#
# Indexes
#
#  index_data_digests_on_data_digest_template_id  (data_digest_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (data_digest_template_id => data_digest_templates.id)
#

require 'rails_helper'

RSpec.describe DataDigests::Payment, type: :model do
  subject(:data_digest) { create(:payment_data_digest) }
  let(:period) { DataDigest.period(:ever) }

  before do
    create_list(:booking, 3, organisation: data_digest.organisation).map do |booking|
      invoice = create(:invoice, booking: booking)
      create(:payment, invoice: invoice, amount: invoice.amount)
    end
  end

  it { is_expected.to be_a(described_class) }

  describe '#evaluate' do
    subject(:periodic_data) { data_digest.evaluate(period) }

    it { is_expected.to be_a(DataDigest::PeriodicData) }
    it {
      is_expected.to have_attributes(header: ['Ref', 'Buchungsreferenz', 'Bezahlt am', 'Betrag', 'Mieter',
                                              'Bemerkungen'])
    }
    it { expect(periodic_data.data.count).to be(3) }
  end

  describe '#csv' do
    it { expect(data_digest.evaluate(period).format(:csv)).to include('Betrag') }
  end

  describe '#pdf' do
    it { expect(data_digest.evaluate(period).format(:pdf)).not_to be_blank }
  end
end
