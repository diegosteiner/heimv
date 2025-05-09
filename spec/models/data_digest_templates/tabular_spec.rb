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

RSpec.describe DataDigestTemplates::Tabular do
  subject(:columns) { data_digest_template.columns }

  let(:data_digest_template) do
    build(:data_digest_template, columns_config:, organisation:).becomes(described_class).tap(&:save)
  end
  let(:organisation) { create(:organisation) }

  describe '#columns' do
    let(:columns_config) do
      [
        {
          header: 'Test Header 1',
          body: '{{ booking.ref }}'
        },
        {
          header: 'Test Header 2',
          body: '{{ booking.name }}'
        }
      ]
    end

    it { expect(columns.count).to eq(2) }
    it { is_expected.to all(be_a DataDigestTemplates::Tabular::Column) }
  end
end
