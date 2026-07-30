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

RSpec.describe Tarifs::OvernightStay do
  let(:booking) do
    create(:booking, begins_at: Time.zone.local(2026, 2, 27, 10), ends_at: Time.zone.local(2026, 3, 2, 16))
  end
  let(:usage) { tarif.build_usage(booking:) }
  let(:tarif) { create(:tarif, type: described_class.sti_name, organisation: booking.organisation) }

  describe 'Usage#booking_dates' do
    context 'with mode :days' do
      it do
        tarif.mode_days!
        expect(usage.booking_dates.map(&:iso8601)).to eq(%w[2026-02-27 2026-02-28 2026-03-01 2026-03-02])
      end
    end

    context 'with mode :nights' do
      it do
        tarif.mode_nights!
        expect(usage.booking_dates.map(&:iso8601)).to eq(%w[2026-02-27 2026-02-28 2026-03-01])
      end
    end
  end

  describe 'Usage#set_used_units' do
    it do
      usage.update(details: { '2026-02-27' => 5, '2026-02-28' => '15', '2026-03-01' => false, 'omg' => 'wtf' })
      expect(usage).to have_attributes(
        details: match_array('2026-02-27' => 5, '2026-02-28' => 15, '2026-03-01' => nil),
        used_units: 20
      )
    end
  end

  describe 'Usage#breakdown' do
    it do
      usage.update(details: { '2026-02-27' => 5, '2026-02-28' => '15' })
      expect(usage.breakdown).to eq('1 x 2')
    end
  end
end
