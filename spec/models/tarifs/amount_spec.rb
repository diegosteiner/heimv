# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                                :bigint           not null, primary key
#  accounting_account_nr             :string
#  accounting_cost_center_nr         :string
#  associated_types                  :integer          default(0), not null
#  discarded_at                      :datetime
#  enabling_conditions               :jsonb
#  label_i18n                        :jsonb
#  minimum_price_per_night           :decimal(, )
#  minimum_price_total               :decimal(, )
#  minimum_usage_per_night           :decimal(, )
#  minimum_usage_total               :decimal(, )
#  mode                              :integer
#  ordinal                           :integer
#  pin                               :boolean          default(TRUE)
#  prefill_usage_method              :string
#  price_per_unit                    :decimal(, )
#  selecting_conditions              :jsonb
#  tarif_group                       :string
#  type                              :string
#  unit_i18n                         :jsonb
#  valid_from                        :datetime
#  valid_until                       :datetime
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  organisation_id                   :bigint           not null
#  prefill_usage_booking_question_id :bigint
#  vat_category_id                   :bigint
#

require 'rails_helper'

RSpec.describe Tarifs::Amount do
  let(:booking) { create(:booking) }

  describe 'Usage#minimum_prices' do
    subject(:minimum_prices) { usage.minimum_prices_difference }

    let(:usage) { tarif.build_usage(booking:) }
    let(:tarif) do
      create(:tarif, type: described_class.sti_name, price_per_unit: 10, organisation: booking.organisation)
    end

    context 'with minimums defined' do
      before do
        tarif.update(
          minimum_usage_per_night: 24,
          minimum_usage_total: 71,
          minimum_price_per_night: 210,
          minimum_price_total: 610
        )
      end

      it 'lists all minimum prices' do
        expect(usage.minimum_prices).to match_array(
          minimum_usage_per_night: (24 * booking.nights) * 10,
          minimum_usage_total: (71 * 10),
          minimum_price_per_night: (210 * booking.nights),
          minimum_price_total: 610
        )
      end

      it { expect(usage.critical_minimum).to eq(:minimum_usage_per_night) }
    end

    context 'without minimums defined' do
      it { expect(usage.critical_minimum).to be_falsy }
    end
  end
end
