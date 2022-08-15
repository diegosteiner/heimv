# frozen_string_literal: true

describe 'Booking', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_rich_text_templates) }
  let(:home) { create(:home, organisation: organisation) }
  let!(:new_booking) { build(:booking, organisation: organisation, home: home, skip_infer_transitions: false) }

  describe 'new', skip: true do
    context 'with correct information' do
      it 'cannot create new booking request' do
        visit new_public_booking_path(booking: { occupancy_attributes: { begins_at: new_booking.occupancy.begins_at } })
        select home.name, from: :booking_home_id
        fill_in 'booking[occupancy_attributes][begins_at_date]',
                with: I18n.l(new_booking.occupancy.begins_at_date, format: :short)
        fill_in 'booking[occupancy_attributes][ends_at_date]', with: 'invalid'
        fill_in :booking_email, with: new_booking.tenant.email
        fill_in :booking_tenant_organisation, with: new_booking.tenant_organisation
        submit_form
        expect(page).to have_content I18n.t('flash.actions.create.alert', resource_name: Booking.model_name.human)
      end
    end

    context 'with missing information' do
      let(:path) do
        { booking: {
          occupancy_attributes: {
            begins_at: new_booking.occupancy.begins_at, ends_at: new_booking.occupancy.ends_at
          }
        } }
      end
      it 'can create new booking request' do
        visit new_public_booking_path
        select home.name, from: :booking_home_id
        visit new_public_booking_path(path)
        fill_in :booking_email, with: new_booking.tenant.email
        fill_in :booking_tenant_organisation, with: new_booking.tenant_organisation
        submit_form
        expect(page).to have_content I18n.t('flash.public.bookings.create.notice',
                                            resource_name: Booking.model_name.human)
      end
    end
  end

  # scenario 'can see a booking' do
  #   booking
  #   visit manage_bookings_path
  #   find_resource_in_table(booking).click
  #   expect(page).to have_current_path(manage_booking_path(booking, org: nil))
  #   expect(page).to have_http_status(200)
  #   expect(page).to have_content booking.ref
  # end

  # scenario 'can edit existing booking' do
  #   visit edit_manage_booking_path(booking, org: nil)
  #   # fill_in :booking_ref, with: new_booking.ref
  #   submit_form
  #   expect(page).to have_http_status(200)
  #   expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Booking.model_name.human)
  # end

  # scenario 'can delete existing booking' do
  #   visit manage_booking_path(booking, org: nil)
  #   click_link I18n.t('destroy')
  #   expect(page).to have_current_path(manage_bookings_path)
  #   expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Booking.model_name.human)
  # end
end
