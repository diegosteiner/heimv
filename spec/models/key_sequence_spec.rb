# frozen_string_literal: true

# == Schema Information
#
# Table name: key_sequences
#
#  id              :bigint           not null, primary key
#  key             :string           not null
#  value           :integer          default(0), not null
#  year            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_key_sequences_on_key_and_year_and_organisation_id  (key,year,organisation_id) UNIQUE
#  index_key_sequences_on_organisation_id                   (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
require 'rails_helper'

RSpec.describe KeySequence, type: :model do
  let(:organisation) { key_sequence.organisation }
  let(:key) { 'test' }
  subject(:key_sequence) { create(:key_sequence, value: 10, key:) }

  describe '#lease!' do
    subject(:lease!) { key_sequence.lease! }

    it { expect { lease! }.to(change { key_sequence.reload.value }.by(1)) }
    it { is_expected.to eq(11) }
  end

  describe '::key' do
    subject { organisation.key_sequences.key(key, year:) }
    let(:year) { nil }

    it { is_expected.to eq(key_sequence) }

    context 'with not existing key_sequence' do
      let(:year) { 2023 }
      it { is_expected.to have_attributes(year:, key:) }
    end

    context 'with :current as year' do
      let(:year) { :current }
      it { is_expected.to have_attributes(year: Time.zone.today.year, key:) }
    end
  end
end
