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
#  included_units_mode               :integer          default(0)
#  label_i18n                        :jsonb
#  minimum                           :decimal(, )
#  minimum_mode                      :integer          default(0)
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

RSpec.describe Tarifs::GroupMinimum do
  let(:home) { create(:home) }
  let(:organisation) { home.organisation }
  let(:booking) { create(:booking, organisation:, home:) }

  let(:tarif_group) { :test }
  let(:price_per_unit) { 10 }
  let(:tarif) { create(:tarif, type: described_class.sti_name, price_per_unit:, organisation:, tarif_group:) }
  let!(:usage) { tarif.build_usage(booking:) }
  let(:other_tarifs) do
    [
      create(:tarif, price_per_unit:, organisation:, tarif_group:),
      create(:tarif, price_per_unit: 12, organisation:, tarif_group:),
      create(:tarif, price_per_unit: 0, organisation:, tarif_group:)
    ]
  end

  before do
    [
      create(:usage, booking:, tarif: other_tarifs[0], used_units: 7),
      create(:usage, booking:, tarif: other_tarifs[1], used_units: 8),
      create(:usage, booking:, tarif: other_tarifs[2], used_units: nil)
    ]
  end

  describe 'Usage#minimum_price' do
    subject(:minimum_price) { usage.minimum_price }

    it 'calculates the tarif group totals' do
      expect(usage.tarif_group_used_units).to eq(15)
      expect(usage.tarif_group_price).to eq(166)
    end

    it do
      tarif.update(minimum_mode: :usage_per_night, minimum: 24)
      expect(usage.tarif).to be_minimum_usage_per_night
      expect(usage.minimum_price).to eq(((24 * 7) - 15) * 10)
      expect(usage.breakdown).to eq('Differenz zum Mindestverbrauch (24 × CHF 10.00 / Nacht)')
    end

    it do
      tarif.update(minimum_mode: :usage_per_day, minimum: 24)
      expect(usage.tarif).to be_minimum_usage_per_day
      expect(usage.minimum_price).to eq(((24 * 8) - 15) * 10)
      expect(usage.breakdown).to eq('Differenz zum Mindestverbrauch (24 × CHF 10.00 / Tag)')
    end

    it do
      tarif.update(minimum_mode: :usage_total, minimum: 71)
      expect(usage.tarif).to be_minimum_usage_total
      expect(usage.breakdown).to eq('Differenz zum Mindestverbrauch (71 × CHF 10.00)')
      expect(usage.minimum_price).to eq((71 - 15) * 10)
    end

    it do
      tarif.update(minimum_mode: :price_per_night, minimum: 210)
      expect(usage.tarif).to be_minimum_price_per_night
      expect(usage.breakdown).to eq('Differenz zum Mindestbetrag (CHF 210.00 / Nacht)')
      expect(usage.minimum_price).to eq((210 * 7) - 166)
    end

    it do
      tarif.update(minimum_mode: :price_per_day, minimum: 210)
      expect(usage.breakdown).to eq('Differenz zum Mindestbetrag (CHF 210.00 / Tag)')
      expect(usage.tarif).to be_minimum_price_per_day
      expect(usage.minimum_price).to eq((210 * 8) - 166)
    end

    it do
      tarif.update(minimum_mode: :price_total, minimum: 610)
      expect(usage.breakdown).to eq('Differenz zum Mindestbetrag (CHF 610.00)')
      expect(usage.tarif).to be_minimum_price_total
      expect(usage.minimum_price).to eq(610 - 166)
    end
  end
end
