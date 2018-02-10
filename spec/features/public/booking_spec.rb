# frozen_string_literal: true

feature 'Booking', :devise, js: true do
  let!(:home) { create(:home) }
  let(:booking) { create(:booking) }
  let(:new_booking) { build(:booking) }

  describe 'new' do
    context 'with all correct information' do
      scenario 'cannot create new booking request' do
        visit new_public_booking_path
        select home.name, from: :booking_home_id
        fill_in :booking_occupancy_attributes_begins_at, with: I18n.l(new_booking.occupancy.begins_at, format: :short)
        fill_in :booking_occupancy_attributes_ends_at, with: 'invalid'
        fill_in :booking_email, with: new_booking.customer.email
        fill_in :booking_organisation, with: new_booking.organisation
        submit_form
        expect(page).to have_http_status(200)
        expect(page).to have_content I18n.t('flash.actions.create.alert', resource_name: Booking.model_name.human)
      end
    end

    context 'with missing information' do
      scenario 'can create new booking request' do
        visit new_public_booking_path
        select home.name, from: :booking_home_id
        fill_in :booking_occupancy_attributes_begins_at, with: I18n.l(new_booking.occupancy.begins_at)
        fill_in :booking_occupancy_attributes_ends_at, with: I18n.l(new_booking.occupancy.ends_at)
        fill_in :booking_email, with: new_booking.customer.email
        fill_in :booking_organisation, with: new_booking.organisation
        submit_form
        expect(page).to have_http_status(200)
        expect(page).to have_content I18n.t('flash.public.bookings.create.notice',
                                            resource_name: Booking.model_name.human)
      end
    end
  end

  # scenario 'can see a booking' do
  #   booking
  #   visit bookings_path
  #   find_resource_in_table(booking).click
  #   expect(page).to have_current_path(booking_path(booking))
  #   expect(page).to have_http_status(200)
  #   expect(page).to have_content booking.ref
  # end

  # scenario 'can edit existing booking' do
  #   visit edit_booking_path(booking)
  #   # fill_in :booking_ref, with: new_booking.ref
  #   submit_form
  #   expect(page).to have_http_status(200)
  #   expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Booking.model_name.human)
  # end

  # scenario 'can delete existing booking' do
  #   visit booking_path(booking)
  #   click_link I18n.t('destroy')
  #   expect(page).to have_current_path(bookings_path)
  #   expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Booking.model_name.human)
  # end
end
