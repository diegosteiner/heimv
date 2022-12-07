# frozen_string_literal: true

# == Schema Information
#
# Table name: booking_conditions
#
#  id               :bigint           not null, primary key
#  distinction      :string
#  group            :string
#  must_condition   :boolean          default(TRUE)
#  qualifiable_type :string
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint
#  qualifiable_id   :bigint
#
# Indexes
#
#  index_booking_conditions_on_organisation_id                      (organisation_id)
#  index_booking_conditions_on_qualifiable                          (qualifiable_id,qualifiable_type,group)
#  index_booking_conditions_on_qualifiable_id_and_qualifiable_type  (qualifiable_id,qualifiable_type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#  fk_rails_...  (qualifiable_id => tarifs.id)
#

require 'rails_helper'

RSpec.describe BookingConditions::Season, type: :model do
  let(:organisation) { create(:organisation) }
  subject(:booking_condition) { described_class.new(distinction: distinction, organisation: organisation) }
  describe '#evaluate' do
    let(:distinction) { '' }
    subject { booking_condition.evaluate(booking) }
    let(:booking) do
      create(:booking, organisation: organisation, begins_at: Time.zone.local(2022, 12, 24),
                       ends_at: Time.zone.local(2023, 1, 3))
    end

    it { is_expected.to be_falsy }

    context 'with non-matching condition' do
      let(:distinction) { '01.03-29.10' }
      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_falsy }
    end

    context 'with matching condition' do
      let(:distinction) { '29.10.-1.3.' }
      it { expect(booking_condition).to be_valid }
      it { is_expected.to be_truthy }
    end
  end

  describe '#valid?' do
    context 'with invalid distinction' do
      let(:distinction) { '81.13-2.99' }
      it { is_expected.not_to be_valid }
    end
  end

  describe '#season_span' do
    subject { booking_condition.send(:season_span, year) }
    let(:year) { 2022 }
    let(:begins_at) { Time.zone.local(year, 3, 1).beginning_of_day }
    let(:ends_at) { Time.zone.local(year, 10, 29).end_of_day }

    context 'with invalid distinction' do
      let(:distinction) { '81.13-2.99' }
      it { is_expected.to eq(nil) }
    end

    context 'within the same year' do
      let(:distinction) { '01.03-29.10' }
      it { is_expected.to eq(begins_at..ends_at) }
    end

    context 'within two years' do
      let(:distinction) { '29.10.-1.3.' }
      let(:begins_at) { Time.zone.local(year, 10, 29).beginning_of_day }
      let(:ends_at) { Time.zone.local(year + 1, 3, 1).end_of_day }
      it { is_expected.to eq(begins_at..ends_at) }
    end
  end

  describe '#phased_season_spans' do
    let(:distinction) { '29.10.-1.3.' }
    subject(:phased_season_spans) { booking_condition.send(:phased_season_spans, [2022, 2023]) }
    subject(:phased_years) { phased_season_spans.map { |span| [span.begin.year, span.end.year] } }
    it { is_expected.to eq([[2021, 2022], [2022, 2023], [2023, 2024], [2024, 2025]]) }
  end
end
