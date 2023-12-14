# frozen_string_literal: true

describe 'Booking by tenant', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:org) { organisation.to_param }
  let(:manager) { create(:organisation_user, :manager, organisation:) }
  let(:user) { manager.user }
  let!(:home) { create(:home, organisation:) }
  let(:tenant) { create(:tenant, organisation:, birth_date: Date.new(1987, 10, 25)) }

  let(:booking) do
    begins_at = Time.zone.local(Time.zone.now.year + 1, 2, 28, 8)
    build(:booking,
          begins_at:, ends_at: begins_at + 1.week + 4.hours + 15.minutes,
          organisation:, home:, tenant: nil, committed_request: false,
          notifications_enabled: false)
  end

  let(:expected_notifications) do
    []
  end

  let(:expected_transitions) do
    %w[provisional_request definitive_request]
  end

  it 'flows through happy path' do
    signin(user, user.password)
    create_booking
    update_booking
    check_booking
  end

  def fill_request_form(email:, begins_at:, ends_at:, home:)
    # select home.id, from: 'booking[home_id]'
    check "booking_occupiable_ids_#{home.id}"
    fill_in 'booking[email]', with: email
    fill_in 'booking_begins_at_date', with: begins_at.strftime('%d.%m.%Y')
    select(format('%02d:00', begins_at.hour), from: 'booking_begins_at_time')
    fill_in 'booking_ends_at_date', with: ends_at.strftime('%d.%m.%Y')
    select(format('%02d:00', ends_at.hour), from: 'booking_ends_at_time')
  end

  def fill_tenant_form(tenant)
    fill_in 'booking_tenant_attributes_first_name', with: tenant.first_name
    fill_in 'booking_tenant_attributes_last_name', with: tenant.last_name
    fill_in 'booking_tenant_attributes_street_address', with: tenant.street_address
    fill_in 'booking_tenant_attributes_zipcode', with: tenant.zipcode
    fill_in 'booking_tenant_attributes_city', with: tenant.city
    fill_in 'booking_tenant_attributes_phone', with: tenant.phone
    fill_in 'booking_tenant_attributes_last_name', with: tenant.last_name

    select(tenant.birth_date.day, from: 'booking_tenant_attributes_birth_date_3i')
    select(tenant.birth_date.month, from: 'booking_tenant_attributes_birth_date_2i')
    select(tenant.birth_date.year, from: 'booking_tenant_attributes_birth_date_1i')
  end

  def create_booking
    visit manage_bookings_path(org:)
    click_link(Booking.model_name.human)
    fill_request_form(email: booking.email, begins_at: booking.begins_at, ends_at: booking.ends_at, home: booking.home)
    fill_tenant_form(tenant)
    uncheck 'booking_notifications_enabled'
    submit_form

    expect(page).to have_content(I18n.t('flash.actions.create.notice', resource_name: Booking.model_name.human))
    expect(@booking = Booking.last).to be_present
  end

  def update_booking
    visit edit_manage_booking_path(id: @booking, org:)
    choose 'booking_committed_request_true'
    select booking.category.title, from: 'booking_booking_category_id'
    submit_form
    expect(page).to have_content(I18n.t('flash.actions.update.notice', resource_name: Booking.model_name.human))
  end

  def check_booking
    expect(@booking.notifications_enabled).to be_falsey
    expect(@booking.state_transitions.ordered.map(&:to_state)).to match_array(expected_transitions)
  end
end
