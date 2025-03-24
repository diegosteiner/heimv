# frozen_string_literal: true

describe 'Booking by agent', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:org) { organisation.to_param }
  let(:organisation_user) { create(:organisation_user, :manager, organisation:) }
  let(:user) { organisation_user.user }
  let(:home) { create(:home, organisation:) }
  let(:tenant) { create(:tenant, organisation:, birth_date: Date.new(1987, 10, 25)) }
  let!(:booking_agent) { create(:booking_agent, code: 'TEST1234', organisation:) }
  let(:agent_ref) { 'test-ref-1234' }

  let(:new_booking_path) do
    new_public_booking_path(booking: { home_id: home.id, begins_at: booking.begins_at.iso8601,
                                       ends_at: booking.ends_at.iso8601 })
  end

  # let!(:booking_question) do
  #   create(:booking_question, organisation:, required: true, type: BookingQuestions::Integer.to_s,
  #                             tenant_mode: :provisional_editable, booking_agent_mode: :provisional_editable)
  # end

  let(:booking) do
    begins_at = Time.zone.local(Time.zone.now.year + 1, 2, 28, 8)
    build(:booking,
          begins_at:, ends_at: begins_at + 1.week + 4.hours + 15.minutes,
          organisation:, home:, tenant: nil, committed_request: false,
          notifications_enabled: true)
  end

  let(:expected_notifications) do
    %w[manage_new_booking_notification
       open_booking_agent_request_notification
       booking_agent_request_notification
       awaiting_tenant_notification
       booking_agent_request_accepted_notification
       manage_definitive_request_notification
       definitive_request_notification]
  end

  let(:expected_transitions) do
    %w[open_request booking_agent_request awaiting_tenant definitive_request]
  end

  it 'flows through happy path' do
    create_agent_booking_request
    signin(user, user.password)
    accept_booking
    commit_agent_booking_request
    enter_tenant_details
    check_booking
  end

  def fill_request_form(email:, begins_at:, ends_at:, home:)
    # select(home.to_s, from: 'booking_home_id')
    check "booking_occupiable_ids_#{home.id}"
    fill_in 'booking_email', with: email
    fill_in 'booking_begins_at_date', with: begins_at.strftime('%d.%m.%Y')
    select(format('%02d:00', begins_at.hour), from: 'booking_begins_at_time')
    fill_in 'booking_ends_at_date', with: ends_at.strftime('%d.%m.%Y')
    select(format('%02d:00', ends_at.hour), from: 'booking_ends_at_time')
    check 'booking_accept_conditions'
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

  def create_agent_booking_request
    visit new_booking_path
    fill_request_form(email: nil, begins_at: booking.begins_at, ends_at: booking.ends_at, home: booking.home)
    click_on 'agent-booking-button'

    choose 'agent_booking[booking_attributes][booking_category_id]', option: booking.category.id
    # expect(page).to have_content(booking_question.label)
    # booking_question_element = find('#agent_booking_booking_attributes_booking_question_responses_attributes_0_value')
    # booking_question_element.click
    # booking_question_element.send_keys('10')
    fill_in 'agent_booking_booking_agent_code', with: booking_agent.code
    fill_in 'agent_booking_booking_agent_ref', with: agent_ref
    submit_form

    expect(page).to have_content(I18n.t('flash.actions.create.notice', resource_name: AgentBooking.model_name.human))
    expect(@agent_booking = AgentBooking.last).to be_valid
    expect(@agent_booking.booking_agent_ref).to eq(agent_ref)
  end

  def commit_agent_booking_request
    visit edit_public_agent_booking_path(@agent_booking.token, org:)

    tenant_infos = [booking.tenant_organisation, booking.purpose_description]
    fill_in 'agent_booking_tenant_infos', with: tenant_infos.join("\n")
    fill_in 'agent_booking_tenant_email', with: booking.email
    submit_form
    expect(page).to have_content(I18n.t('flash.actions.update.notice',
                                        resource_name: AgentBooking.model_name.human))

    click_button BookingActions::CommitBookingAgentRequest.t(:label)
  end

  def accept_booking
    visit manage_booking_path(@agent_booking.booking, org:)
    click_button BookingActions::Accept.t(:label)
  end

  def enter_tenant_details
    visit edit_public_booking_path(id: @agent_booking.booking.token)
    fill_in 'booking_approximate_headcount', with: booking.approximate_headcount
    fill_in 'booking_tenant_organisation', with: booking.tenant_organisation
    fill_in 'booking_purpose_description', with: booking.purpose_description
    fill_tenant_form(tenant)
    submit_form
    expect(page).to have_content(I18n.t('flash.public.bookings.update.notice'))
  end

  def check_booking
    booking = @agent_booking.booking.reload
    expect(booking.notifications.map { |notification| notification.mail_template.key })
      .to match_array(expected_notifications)
    expect(booking.state_transitions.ordered.map(&:to_state)).to match_array(expected_transitions)
  end
end
