# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OccupancyCalendar do
  subject(:calendar) { described_class.new(organisation:, occupiables: [occupiable]) }

  let(:organisation) { create(:organisation, settings: { booking_window: 'P1Y' }) }
  let(:occupiable) { create(:occupiable, organisation:) }
  let(:other_occupiable) { create(:occupiable, organisation:) }

  describe '#occupancies' do
    subject { calendar.occupancies }

    let!(:occupancies) do
      {
        visible_occupied: create(:occupancy, occupiable:, occupancy_type: :occupied,
                                             begins_at: 1.week.from_now, ends_at: 2.weeks.from_now),
        visible_closed: create(:occupancy, occupiable:, occupancy_type: :closed,
                                           begins_at: 3.weeks.from_now, ends_at: 4.weeks.from_now),
        invisible_pending: create(:occupancy, occupiable:, occupancy_type: :pending,
                                              begins_at: 5.weeks.from_now, ends_at: 6.weeks.from_now),
        invisible_other_occupancy: create(:occupancy, occupiable: other_occupiable, occupancy_type: :occupied,
                                                      begins_at: 7.weeks.from_now, ends_at: 8.weeks.from_now),
        invisible_past: create(:occupancy, occupiable:, occupancy_type: :occupied,
                                           begins_at: 2.weeks.ago, ends_at: 1.week.ago),
        invisible_future: create(:occupancy, occupiable:, occupancy_type: :occupied,
                                             begins_at: 3.years.from_now, ends_at: (3.years + 1.week).from_now)
      }
    end

    before do
      organisation.settings.public_occupancy_visibility = %w[occupied closed]
    end

    it 'returns only occupancies that should be displayed in the calendar' do
      is_expected.to match_array(occupancies.slice(:visible_occupied, :visible_closed).values)
    end
  end
end
