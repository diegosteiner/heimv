# frozen_string_literal: true

describe 'Data Digests', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }
  let(:user) { organisation_user.user }
  let(:home) { create(:home, organisation:) }
  let(:booking) { create(:booking, organisation:, home:, skip_infer_transitions: false) }
  let(:data_digest) { create(:data_digest, type: DataDigestTemplates::Booking, organisation:) }

  before do
    signin(user, user.password)
  end

  it 'can create new data digest' do
    name = 'Test Data Digest 123'
    visit new_manage_data_digest_template_path(type: DataDigestTemplates::Booking, org: organisation)
    fill_in :data_digest_template_label, with: name
    submit_form

    expect(page).to have_content I18n.t('flash.actions.create.notice',
                                        resource_name: DataDigestTemplates::Booking.model_name.human)
    expect(page).to have_content name
  end

  it 'can see a booking', :skip do
    visit manage_data_digest_path(data_digest, org: organisation)
    bookings = create_list(:booking, 3, organisation:, home:)
    click_on I18n.t('activerecord.enums.data_digest.periods.ever')
    bookings.each { |booking| expect(page).to have_content booking.ref }
    click_on 'CSV'
    bookings.each { |booking| expect(page).to have_content booking.ref }
  end
end
