# frozen_string_literal: true

describe 'Data Digests', :devise do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }
  let(:user) { organisation_user.user }
  let(:home) { create(:home, organisation:) }
  let(:booking) { create(:booking, organisation:, home:, skip_infer_transitions: false) }
  let!(:data_digest_template) do
    create(:data_digest_template, label: 'Testdigest', type: DataDigestTemplates::Booking, organisation:)
  end

  before do
    signin(user, user.password)
  end

  it 'can create new data digest' do
    label = 'Test Data Digest 123'
    visit new_manage_data_digest_template_path(type: DataDigestTemplates::Booking, org: organisation)
    visit new_manage_data_digest_template_path(type: DataDigestTemplates::Booking, org: organisation) # capybara issue
    fill_in :data_digest_template_label, with: label
    submit_form

    expect(page).to have_content I18n.t('flash.actions.create.notice',
                                        resource_name: DataDigestTemplates::Booking.model_name.human)
    expect(page).to have_content label
  end

  it 'can see a booking', skip: 'broken on CI' do
    visit manage_data_digest_templates_path(org: organisation)
    click_on data_digest_template.label
    bookings = create_list(:booking, 3, organisation:, home:)
    select I18n.t('activerecord.enums.data_digest.periods.ever'), from: :data_digest_period
    # click_button I18n.t('helpers.submit.create')
    submit_form
    sleep 0.5

    click_on data_digest_template.label
    bookings.each { |booking| expect(page).to have_content booking.ref }
    click_on 'CSV'
    bookings.each { |booking| expect(page).to have_content booking.ref }
  end
end
