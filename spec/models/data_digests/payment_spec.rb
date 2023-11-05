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

RSpec.describe DataDigestTemplates::Payment, type: :model do
  subject(:data_digest) { data_digest_template.data_digests.create }

  let(:columns_config) { nil }
  let(:data_digest_template) do
    create(:payment_data_digest_template, columns_config:)
  end

  before do
    create_list(:booking, 3, organisation: data_digest.organisation).map do |booking|
      invoice = create(:invoice, booking:)
      create(:payment, invoice:, amount: invoice.amount)
    end
    data_digest.crunch!
  end

  describe '#data' do
    it { is_expected.to be_a(DataDigest) }

    it do
      expect(data_digest.header).to eq ['Ref', 'Buchungsreferenz', 'Bezahlt am', 'Betrag', 'Mieter', 'Bemerkungen']
    end

    it { expect(data_digest.data.count).to be(3) }
  end

  describe '#csv' do
    it { expect(data_digest.format(:csv)).to include('Betrag') }
  end

  describe '#pdf' do
    it { expect(data_digest.format(:pdf)).not_to be_blank }
  end
end
