# frozen_string_literal: true

describe 'RichTextTemplate', :devise do
  let(:organisation) { create(:organisation) }
  let(:org) { organisation.to_param }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }
  let(:rich_text_template) { organisation.rich_text_templates.find_by(key: :email_contract_notification) }

  before do
    RichTextTemplateService.new(organisation).create_missing!
    signin(organisation_user.user, organisation_user.user.password)
  end

  it 'can list all rich_text_templates' do
    visit manage_rich_text_templates_path(org:)
    RichTextTemplate.definitions.each_key do |template_key|
      expect(page).to have_content I18n.t(:description, scope: [:rich_text_templates, template_key])
    end
  end

  it 'can show rich_text_template' do
    visit manage_rich_text_template_path(rich_text_template, org:)
    expect(page).to have_content rich_text_template.title
    Rails::HTML::FullSanitizer.new.sanitize(rich_text_template.body).lines.each do |line|
      expect(page).to have_content(line.strip)
    end
  end

  it 'can edit existing rich_text_template' do
    changed_title = 'CHANGED TITLE'

    visit edit_manage_rich_text_template_path(rich_text_template, org:)
    fill_in :rich_text_template_title_de, with: changed_title
    find('.tox-edit-area').click

    submit_form
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: RichTextTemplate.model_name.human)
    expect(page).to have_content changed_title
  end
end
