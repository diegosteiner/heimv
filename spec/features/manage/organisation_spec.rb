# frozen_string_literal: true

describe 'Organisation' do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }
  let(:user) { organisation_user.user }
  let(:home) { create(:home, organisation:) }

  before do
    signin(user, user.password)
  end

  it 'allows to change organisation settings' do
    visit edit_manage_organisation_path
    fill_in :organisation_name, with: 'CHANGED'
    fill_in :organisation_settings_default_begins_at_time, with: '12:34'
    submit_form

    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Organisation.model_name.human)
    expect(organisation.reload).to have_attributes(
      name: 'CHANGED',
      settings: have_attributes({ default_begins_at_time: '12:34' })
    )
  end
end
