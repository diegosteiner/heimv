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
# Indexes
#
#  index_data_digest_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'rails_helper'

RSpec.describe DataDigestTemplate, type: :model do
  subject(:data_digest_template) { create(:data_digest_template) }

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

    subject(:data_digest) { create(:data_digest, columns_config: columns_config) }
    subject(:columns) { data_digest.columns }

    it { expect(columns.count).to eq(2) }
    it { is_expected.to all(be_a DataDigest::Column) }
  end
end
