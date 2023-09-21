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

  describe '#create' do
    subject(:deadline) { booking.deadlines.create(length: length) }

    context 'with length set' do
      let(:length) { 1.week }

      it 'creates armed deadline' do
        expect(deadline.armed).to be_truthy
        expect(deadline.at).to be > 5.days.from_now
        expect(deadline.at).to be < 9.days.from_now
      end
    end

    context 'with length not set' do
      let(:length) { nil }

      it 'creates unarmed deadline' do
        expect(deadline.armed).to be_falsy
        expect(deadline.at).to be_nil
      end
    end

    context 'with length not set' do
      let(:length) { 0 }

      it 'creates unarmed deadline' do
        expect(deadline.armed).to be_falsy
        expect(deadline.at).to be_nil
      end
    end
  end
end
