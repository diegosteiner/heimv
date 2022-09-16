# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                      :bigint           not null, primary key
#  accountancy_account     :string
#  invoice_types           :integer          default(0), not null
#  label_i18n              :jsonb
#  minimum_usage_per_night :decimal(, )
#  minimum_usage_total     :decimal(, )
#  ordinal                 :integer
#  pin                     :boolean          default(TRUE)
#  prefill_usage_method    :string
#  price_per_unit          :decimal(, )
#  tarif_group             :string
#  tenant_visible          :boolean          default(TRUE)
#  type                    :string
#  unit_i18n               :jsonb
#  valid_from              :datetime
#  valid_until             :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  booking_id              :uuid
#  home_id                 :bigint
#
# Indexes
#
#  index_tarifs_on_booking_id  (booking_id)
#  index_tarifs_on_home_id     (home_id)
#  index_tarifs_on_type        (type)
#

require 'rails_helper'

RSpec.describe Organisation, type: :model do
  let(:home) { create(:home) }
  let(:organisation) { home.organisation }
  let(:booking) { create(:booking, home: home) }
  let(:tarif) { create(:tarif, type: Tarifs::Amount.to_s, price_per_unit: 10) }
  let(:usage) { create(:usage, booking: booking, tarif: tarif, used_units: 7) }

  describe '#save' do
    it { expect(tarif.save).to be true }
  end

  describe '#price' do
    subject(:price) { tarif.price(usage) }
    it { is_expected.to eq(70.0) }
    # it { expect(tarif.minimum_price?(usage)).to be_falsy }

    # context 'with minimum_price_total' do
    #   before { tarif.update(minimum_price_total: 100.0) }
    #   it { is_expected.to eq(100.0) }
    #   it { expect(tarif.minimum_price?(usage)).to be_truthy }
    # end

    # context 'with minimum_price_per_night' do
    #   before { tarif.update(minimum_price_per_night: 100.0) }
    #   it { expect(booking.occupancy.nights).to eq(7) }
    #   it { is_expected.to eq(700.0) }
    #   it { expect(tarif.minimum_price?(usage)).to be_truthy }
    # end
  end
end
