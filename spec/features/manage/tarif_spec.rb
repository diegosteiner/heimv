# frozen_string_literal: true

describe 'Tarif', :devise, type: :feature do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:org) { organisation.to_param }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }
  let!(:tarifs) { create_list(:tarif, 3, organisation:) }
  let(:tarif) { tarifs.last }

  before do
    signin(organisation_user.user, organisation_user.user.password)
  end

  it 'can create new tarif' do
    new_tarif = build(:tarif, organisation:)
    visit new_manage_tarif_path(org:)
    select new_tarif.class.model_name.human, from: :tarif_type
    fill_in :tarif_label_de, with: new_tarif.label
    fill_in :tarif_unit_de, with: new_tarif.unit
    fill_in :tarif_price_per_unit, with: new_tarif.price_per_unit
    submit_form
    expect(page).to have_content I18n.t('flash.actions.create.notice', resource_name: Tarif.model_name.human)
  end

  it 'can edit existing tarif' do
    visit edit_manage_tarif_path(tarif, org:)
    fill_in :tarif_label_de, with: 'Updated'
    fill_in :tarif_unit_de, with: 'Updated'
    fill_in :tarif_price_per_unit, with: 1234
    submit_form
    expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Tarif.model_name.human)
  end

  it 'can delete existing tarif' do
    visit manage_tarifs_path(org:)
    within find_resource_in_table(tarif) do
      click_link I18n.t('destroy')
    end
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content I18n.t('flash.actions.destroy.notice', resource_name: Tarif.model_name.human)
  end
end
