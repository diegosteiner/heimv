# == Schema Information
#
# Table name: tarifs
#
#  id                       :bigint(8)        not null, primary key
#  type                     :string
#  label                    :string
#  transient                :boolean          default(FALSE)
#  booking_id               :uuid
#  home_id                  :bigint(8)
#  booking_copy_template_id :bigint(8)
#  unit                     :string
#  price_per_unit           :decimal(, )
#  valid_from               :datetime
#  valid_until              :datetime
#  position                 :integer
#  tarif_group              :string
#  invoice_type             :string
#  prefill_usage_method     :string
#  meter                    :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'rails_helper'

RSpec.describe Tarif, type: :model do
  let(:home) { create(:home) }

  describe 'scope "applicable_to"' do
    let(:booking) do
      build(:booking, home: home).tap do |booking|
        allow(booking).to receive(:state_transition)
        booking.save
      end
    end
    let(:transient_tarifs) { create_list(:tarif, 2, home: home, transient: true) }
    let(:booking_tarifs) { create_list(:tarif, 2, home: home, booking: booking, transient: true) }

    let!(:expected) { [transient_tarifs.to_a, booking_tarifs.to_a].flatten }
    let!(:unexpected) { create_list(:tarif, 2, home: home, transient: false) }

    subject { described_class.applicable_to(booking) }

    it do
      is_expected.to include(*expected)
      is_expected.not_to include(*unexpected)
    end
  end
end
