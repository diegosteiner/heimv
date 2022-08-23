# frozen_string_literal: true

# == Schema Information
#
# Table name: usages
#
#  id                  :bigint           not null, primary key
#  committed           :boolean          default(FALSE)
#  presumed_used_units :decimal(, )
#  price_per_unit      :decimal(, )
#  remarks             :text
#  used_units          :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid
#  tarif_id            :bigint
#
# Indexes
#
#  index_usages_on_booking_id               (booking_id)
#  index_usages_on_tarif_id_and_booking_id  (tarif_id,booking_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (tarif_id => tarifs.id)
#

require 'rails_helper'

RSpec.describe Usage, type: :model do
  describe '#price' do
    let(:tarif) { create(:tarif, price_per_unit: 3.33) }
    let(:usage) { build(:usage, tarif: tarif, used_units: 2) }
    subject { usage.price }

    it { is_expected.to eq(6.65) }
  end

  describe '#save' do
    let(:usage) { build(:usage) }

    it { expect(usage.save!).to be true }
  end
end
