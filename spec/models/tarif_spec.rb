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

RSpec.describe Tarif do
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
end
