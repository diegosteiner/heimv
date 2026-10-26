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
#  included_units                    :decimal(, )
#  included_units_mode               :integer          default("none")
#  label_i18n                        :jsonb
#  minimum                           :decimal(, )
#  minimum_mode                      :integer          default("none")
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

RSpec.describe Tarifs::Price do
  let(:booking) { create(:booking) }
  let(:usage) { tarif.build_usage(booking:) }
  let(:tarif) { create(:tarif, :price, organisation: booking.organisation, price_per_unit: 42.0) }

  describe 'Usage#used_units' do
    it 'returns the price_per_unit' do
      expect(usage.price_per_unit).to eq(42.0)
    end
  end

  describe 'Usage#price' do
    context 'with price_per_unit set' do
      it 'calculates price from used_units and price_per_unit' do
        usage.save
        expect(usage.price).to eq(42.0)
        usage.update!(price_per_unit: 5.0)
        expect(usage.price).to eq(5.0)
      end
    end

    context 'with minimum_price' do
      before do
        tarif.update(price_per_unit: 20, minimum: 50, minimum_mode: :price_total)
      end

      it 'applies minimum price logic' do
        expect(usage.price).to eq(50)
      end
    end
  end

  describe 'Usage#breakdown' do
    subject(:breakdown) { usage.breakdown }

    context 'with used_units' do
      before { usage.update(price_per_unit: 42.50) }

      it 'returns currency formatted used_units' do
        expect(breakdown).to eq(number_to_currency(42.5, unit: booking.organisation.currency))
      end
    end

    context 'with zero used_units' do
      before { usage.update(price_per_unit: 0) }

      it 'returns zero in currency format' do
        expect(breakdown).to eq(number_to_currency(0, unit: booking.organisation.currency))
      end
    end
  end
end
