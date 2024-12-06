# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                                :bigint           not null, primary key
#  accounting_account_nr             :string
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
#  vat                               :decimal(, )
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  organisation_id                   :bigint           not null
#  prefill_usage_booking_question_id :bigint
#
# Indexes
#
#  index_tarifs_on_discarded_at                       (discarded_at)
#  index_tarifs_on_organisation_id                    (organisation_id)
#  index_tarifs_on_prefill_usage_booking_question_id  (prefill_usage_booking_question_id)
#  index_tarifs_on_type                               (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#  fk_rails_...  (prefill_usage_booking_question_id => booking_questions.id)
#

require 'rails_helper'

RSpec.describe Tarifs::GroupMinimum, type: :model do
  let(:home) { create(:home) }
  let(:organisation) { home.organisation }
  let(:booking) { create(:booking, organisation:, home:) }

  let(:tarif_group) { :test }
  let(:price_per_unit) { 10 }
  let(:tarif) { create(:tarif, type: described_class.sti_name, price_per_unit:, organisation:, tarif_group:) }
  let(:other_tarif1) { create(:tarif, price_per_unit:, organisation:, tarif_group:) }
  let(:other_tarif2) { create(:tarif, price_per_unit: 12, organisation:, tarif_group:) }
  let(:other_tarif3) { create(:tarif, price_per_unit: 0, organisation:, tarif_group:) }
  let!(:usage) { create(:usage, booking:, tarif:) }
  let!(:other_usage1) { create(:usage, booking:, tarif: other_tarif1, used_units: 7) }
  let!(:other_usage2) { create(:usage, booking:, tarif: other_tarif2, used_units: 8) }
  let!(:other_usage3) { create(:usage, booking:, tarif: other_tarif3, used_units: nil) }

  describe '#minimum_prices' do
    subject(:minimum_prices) { tarif.minimum_prices_with_difference(usage) }
    before do
      tarif.update({
                     minimum_usage_per_night: 24,
                     minimum_usage_total: 71,
                     minimum_price_per_night: 210,
                     minimum_price_total: 610
                   })
    end

    it 'lists all minimum prices' do
      expect(tarif.group_price(usage)).to eq((7 * 10) + (8 * 12))
      expect(tarif.group_used_units(usage)).to eq(7 + 8)
      expect(minimum_prices).to eq({
                                     minimum_usage_per_night: ((24 * 7) - 15) * 10,
                                     minimum_usage_total: ((71 - 15) * 10),
                                     minimum_price_per_night: (210 * 7) - ((7 * 10) + (8 * 12)),
                                     minimum_price_total: 610 - ((7 * 10) + (8 * 12))
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
      expect(minimum_price.first).to eq(:minimum_usage_per_night)
    end
  end
end
