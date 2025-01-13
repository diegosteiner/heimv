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
#  label_i18n                        :jsonb
#  minimum_price_per_night           :decimal(, )
#  minimum_price_total               :decimal(, )
#  minimum_usage_per_night           :decimal(, )
#  minimum_usage_total               :decimal(, )
#  ordinal                           :integer
#  pin                               :boolean          default(TRUE)
#  prefill_usage_method              :string
#  price_per_unit                    :decimal(, )
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

RSpec.describe Tarif, type: :model do
  let(:home) { create(:home) }
  let(:organisation) { home.organisation }
  let(:booking) { create(:booking, organisation:, home:) }
  let(:tarif) { create(:tarif, type: Tarifs::Amount.to_s, price_per_unit: 10, organisation:) }
  let(:usage) { create(:usage, booking:, tarif:, used_units: 7) }

  describe '#save' do
    it { expect(tarif.save).to be true }
  end

  describe '#price' do
    subject(:price) { usage.price }

    it { is_expected.to eq(70.0) }
  end

  describe '#minimum_prices' do
    subject(:minimum_prices) { usage.tarif.minimum_prices(usage) }
    before do
      tarif.update({
                     minimum_usage_per_night: 24,
                     minimum_usage_total: 71,
                     minimum_price_per_night: 210,
                     minimum_price_total: 610
                   })
    end

    it 'lists all minimum prices' do
      expect(minimum_prices).to eq({
                                     minimum_usage_per_night: 24 * 7 * 10,
                                     minimum_usage_total: 71 * 10,
                                     minimum_price_per_night: 210 * 7,
                                     minimum_price_total: 610
                                   })
    end
  end

  describe '#minimum_price' do
    subject(:minimum_price) { usage.tarif.minimum_price(usage) }
    before do
      tarif.update({
                     minimum_usage_per_night: 24,
                     minimum_usage_total: 71,
                     minimum_price_per_night: 210,
                     minimum_price_total: 610
                   })
    end

    it 'lists all minimum prices' do
      expect(minimum_price).to eq([:minimum_usage_per_night, 24 * 7 * 10])
    end
  end
end
