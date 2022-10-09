# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
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
# Indexes
#
#  index_data_digests_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe DataDigests::InvoicePart, type: :model do
  subject(:data_digest) { create(:invoice_part_data_digest, organisation: organisation) }
  let(:period) { DataDigest.period(:ever) }
  let(:home) { create(:home, organisation: organisation) }
  let(:organisation) { create(:organisation) }
  let(:tarifs) { create_list(:tarif, 4, organisation: organisation, home: home) }

  let!(:invoice_parts) do
    create_list(:booking, 3, home: home).map do |booking|
      invoice = create(:invoice, booking: booking)
      tarifs.map do |tarif|
        usage = create(:usage, booking: booking, tarif: tarif)
        create(:invoice_part, invoice: invoice, usage: usage)
      end
    end.flatten
  end

  it { is_expected.to be_a(described_class) }

  describe '#evaluate' do
    subject(:periodic_data) { data_digest.evaluate(period) }

    it { is_expected.to be_a(DataDigest::PeriodicData) }
    # it { expect(periodic_data.data.count).to be(invoice_parts.count) }
    # it(:header) do
    #   is_expected.to have_attributes(header: ['Referenznummer', 'Buchungsreferenz', 'Paid at', 'Ausgestellt am',
    #                      'Tarifbezeichnung', 'Text', 'Aufschlüsselung', 'Betrag', 'Remarks'])
    # end
  end

  describe '#csv' do
    it { expect(data_digest.evaluate(period).format(:csv)).to include('Betrag') }
  end

  describe '#pdf' do
    it { expect(data_digest.evaluate(period).format(:pdf)).not_to be_blank }
  end
end
