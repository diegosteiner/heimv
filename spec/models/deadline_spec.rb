# frozen_string_literal: true

# == Schema Information
#
# Table name: deadlines
#
#  id               :bigint           not null, primary key
#  armed            :boolean          default(TRUE)
#  at               :datetime
#  postponable_for  :integer          default(0)
#  remarks          :text
#  responsible_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  booking_id       :uuid
#  responsible_id   :bigint
#
# Indexes
#
#  index_deadlines_on_booking_id   (booking_id)
#  index_deadlines_on_responsible  (responsible_type,responsible_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

require 'rails_helper'

RSpec.describe Deadline, type: :model do
  let(:booking) { create(:booking) }
  let(:deadline) { build(:deadline, booking: booking) }

  describe '#save' do
    context 'with no deadline in place' do
      it do
        expect(booking.deadline).to be(nil)
        deadline.save
        expect(booking.deadline).to eq(deadline)
      end
    end
  end
end
