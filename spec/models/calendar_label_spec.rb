# frozen_string_literal: true

require 'rails_helper'

# == Schema Information
#
# Table name: calendar_labels
#
#  id                          :bigint           not null, primary key
#  color                       :string           not null
#  conflict_type_default       :integer
#  description_i18n            :jsonb            not null
#  discarded_at                :datetime
#  legend                      :boolean          default(TRUE), not null
#  ordinal                     :integer
#  title_i18n                  :jsonb            not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  booking_categories_id       :bigint
#  booking_category_default_id :bigint
#  organisation_id             :bigint
#
describe CalendarLabel do
  let(:organisation) { booking.organisation }
  let(:booking) { create(:booking) }

  describe 'with specific calendar label set' do
    let(:calendar_label) { create(:calendar_label, organisation:, conflict_type_default: nil, title: 'Internal') }

    it do
      booking.update!(calendar_label:)
      expect(booking.reload.occupancies).to all(have_attributes(calendar_label:))
    end
  end

  describe 'with no calendar label set' do
    context 'with tentative status' do
      it do
        default_calendar_label = organisation.calendar_labels.find_by!(conflict_type_default: :tentative)
        booking.update!(conflict_type: :tentative)
        expect(booking.reload.occupancies).to all(have_attributes(calendar_label: default_calendar_label))
      end
    end

    context 'with occupied status' do
      let(:calendar_label) { organisation.calendar_labels.find_by!(conflict_type_default: :occupied) }

      it do
        booking.update!(conflict_type: :occupied)
        expect(booking.reload.occupancies).to all(have_attributes(calendar_label:))
      end
    end

    context 'with booking category' do
      let(:booking_category) { create(:booking_category, organisation:) }
      let!(:calendar_label) { create(:calendar_label, organisation:, booking_category_default: booking_category) }

      it do
        booking.update!(category: booking_category)
        expect(booking.reload.occupancies).to all(have_attributes(calendar_label:))
      end
    end
  end
end
