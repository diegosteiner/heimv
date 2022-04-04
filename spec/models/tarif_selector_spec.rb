# frozen_string_literal: true

# == Schema Information
#
# Table name: tarif_selectors
#
#  id          :bigint           not null, primary key
#  distinction :string
#  type        :string
#  veto        :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tarif_id    :bigint
#
# Indexes
#
#  index_tarif_selectors_on_tarif_id  (tarif_id)
#
# Foreign Keys
#
#  fk_rails_...  (tarif_id => tarifs.id)
#

require 'rails_helper'

RSpec.describe TarifSelector, type: :model do
  describe 'OccupancyDuration' do
    let(:selector) { TarifSelectors::OccupancyDuration.new(distinction: distinction) }
    let(:distinction) { '' }
    let(:usage) { create(:usage, booking: booking) }
    let(:duration) { 1.week }
    let(:booking) { create(:booking, begins_at: 1.month.from_now, ends_at: (1.month.from_now + duration)) }

    subject { selector.apply?(usage) }

    it { is_expected.to be_falsy }

    context 'with <8h but booking 1w' do
      let(:distinction) { '<8h' }
      it { is_expected.to be_falsy }
    end

    context 'with >1d and booking 1w' do
      let(:distinction) { '>1d' }
      it { is_expected.to be_truthy }
    end
  end
end
