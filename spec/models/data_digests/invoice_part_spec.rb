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

RSpec.describe DataDigestTemplates::InvoicePart, type: :model do
  subject(:data_digest) { data_digest_template.data_digests.create }
  let(:columns_config) { nil }
  let(:data_digest_template) do
    create(:invoice_part_data_digest_template, columns_config: columns_config, organisation: organisation)
  end
  let(:home) { create(:home, organisation: organisation) }
  let(:organisation) { create(:organisation) }
  let(:tarifs) { create_list(:tarif, 4, organisation: organisation) }
  before do
    data_digest.crunch!
  end

  let!(:invoice_parts) do
    create_list(:booking, 3, home: home).map do |booking|
      invoice = create(:invoice, booking: booking)
      tarifs.map do |tarif|
        usage = create(:usage, booking: booking, tarif: tarif)
        create(:invoice_part, invoice: invoice, usage: usage)
      end
    end.flatten
  end

  describe '#data' do
    it { is_expected.to be_a(DataDigest) }
    # it { expect(periodic_data.data.count).to be(invoice_parts.count) }
    # it(:header) do
    #   is_expected.to have_attributes(header: ['Referenznummer', 'Buchungsreferenz', 'Paid at', 'Ausgestellt am',
    #                      'Tarifbezeichnung', 'Text', 'Aufschlüsselung', 'Betrag', 'Remarks'])
    # end
  end

  describe '#csv' do
    it { expect(data_digest.format(:csv)).to include('Betrag') }
  end

  describe '#pdf' do
    it { expect(data_digest.format(:pdf)).not_to be_blank }
  end
end
