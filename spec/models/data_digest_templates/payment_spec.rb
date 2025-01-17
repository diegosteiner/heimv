# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digest_templates
#
#  id               :bigint           not null, primary key
#  columns_config   :jsonb
#  group            :string
#  label            :string
#  prefilter_params :jsonb
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#

require 'rails_helper'

RSpec.describe DataDigestTemplates::Payment, type: :model do
  subject(:data_digest_template) do
    build(:data_digest_template, columns_config:, organisation:).becomes(described_class).tap(&:save)
  end
  subject(:data_digest) { data_digest_template.data_digests.create }

  let(:organisation) { create(:organisation) }
  let(:columns_config) { nil }

  before do
    create_list(:booking, 3, organisation:).map do |booking|
      invoice = create(:invoice, booking:)
      create(:payment, invoice:, amount: invoice.amount)
    end
    data_digest.crunch!
  end

  describe '#data' do
    it { is_expected.to be_a(DataDigest) }

    it do
      expect(data_digest.data_digest_template.header).to eq ['Ref', 'Buchungsreferenz', 'Bezahlt am', 'Betrag',
                                                             'Mieter', 'Bemerkungen']
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
