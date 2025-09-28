# frozen_string_literal: true

describe 'Bookings' do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }
  let(:user) { organisation_user.user }
  let(:home) { create(:home, organisation:) }
  let(:bookings) { create_list(:booking, 3, organisation:, home:) }
  let(:definitive_request) do
    create(:booking, organisation:, home:, begins_at: 13.months.from_now).tap do |booking|
      booking.update(committed_request: true, transition_to: :definitive_request)
    end
  end

  before do
    bookings
    definitive_request
    signin(user, user.password)
  end

  context OccupancyCalendar.to_s do
    it do
      visit calendar_manage_bookings_path
      expect(page).to have_content(Time.zone.now.year)

      date_element = find("time.date[datetime='#{definitive_request.begins_at.to_date.iso8601}']")
      svg_selector = "a.date-action .occupancy-calendar-date.has-occupancies svg .occupancy-slot[fill='#e85f5f']"
      expect(date_element).to have_selector(svg_selector)
      date_element.click
      expect(page).to have_content(definitive_request.ref)
    end
  end

  context Booking::Filter.to_s do
    it 'can search with the searchbar' do
      visit manage_root_path
      find_by_id('searchbar_query').fill_in with: definitive_request.ref
      within(id: 'searchbar') { click_button }

      expect(page).to have_content definitive_request.ref
      bookings.each { expect(page).to have_no_content(it.ref) }
    end

    it 'can search with the filter' do
      visit manage_bookings_path
      click_on I18n.t('filter')

      within '#filter_previous_booking_states' do
        find('option[value=definitive_request]').click
      end
      submit_form

      expect(page).to have_content definitive_request.ref
      bookings.each { expect(page).to have_no_content(it.ref) }
    end
  end
end
