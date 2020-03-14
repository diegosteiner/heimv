# == Schema Information
#
# Table name: tarifs
#
#  id                       :bigint           not null, primary key
#  invoice_type             :string
#  label                    :string
#  meter                    :string
#  position                 :integer
#  prefill_usage_method     :string
#  price_per_unit           :decimal(, )
#  tarif_group              :string
#  transient                :boolean          default("false")
#  type                     :string
#  unit                     :string
#  valid_from               :datetime
#  valid_until              :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  booking_copy_template_id :bigint
#  booking_id               :uuid
#  home_id                  :bigint
#
# Indexes
#
#  index_tarifs_on_booking_copy_template_id  (booking_copy_template_id)
#  index_tarifs_on_booking_id                (booking_id)
#  index_tarifs_on_home_id                   (home_id)
#  index_tarifs_on_type                      (type)
#

require 'rails_helper'

RSpec.describe Tarif, type: :model do
  let(:home) { create(:home) }

  describe 'scope "applicable_to"' do
    subject { described_class.applicable_to(booking) }

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

    it do
      expect(subject).to include(*expected)
      expect(subject).not_to include(*unexpected)
    end
  end
end
