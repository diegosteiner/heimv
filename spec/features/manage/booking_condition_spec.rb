# frozen_string_literal: true

describe 'BookingCondition', :devise do
  let(:organisation) { create(:organisation, :with_templates) }
  let(:org) { organisation.to_param }
  let(:organisation_user) { create(:organisation_user, :admin, organisation:) }

  before do
    signin(organisation_user.user, organisation_user.user.password)
  end

  def manipulate_conditions
    click_button I18n.t(:add_record, model_name: BookingCondition.model_name.human)
    click_link BookingConditions::Never.model_name.human
    click_button title: I18n.t(:destroy), match: :first
    click_button I18n.t(:add_record, model_name: BookingCondition.model_name.human), match: :first
    click_link BookingConditions::AllOf.model_name.human
    click_button I18n.t(:add_record, model_name: BookingCondition.model_name.human), match: :first
    click_link BookingConditions::Always.model_name.human
  end

  def check_conditions(conditions)
    expect(conditions).to contain_exactly(be_a(BookingConditions::AllOf))
    expect(conditions).to contain_exactly(have_attributes(conditions: contain_exactly(be_a(BookingConditions::Always))))
  end

  describe 'on tarif' do
    let(:tarif) { create(:tarif, organisation:) }

    it 'add selecting conditions' do
      visit edit_manage_tarif_path(tarif, org:)
      within '#selecting_conditions' do
        manipulate_conditions
      end
      submit_form
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Tarif.model_name.human)
      check_conditions(tarif.reload.selecting_conditions)
    end

    it 'add enabling conditions' do
      visit edit_manage_tarif_path(tarif, org:)
      within '#enabling_conditions' do
        manipulate_conditions
      end
      submit_form
      page.scroll_to '#enabling_conditions'
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: Tarif.model_name.human)
      check_conditions(tarif.reload.enabling_conditions)
    end
  end

  describe 'on BookingValidation' do
    let(:validation) { create(:booking_validation, organisation:) }

    it 'add enabling conditions' do
      visit edit_manage_booking_validation_path(validation, org:)
      within '#enabling_conditions' do
        manipulate_conditions
      end
      submit_form
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: '')
      check_conditions(validation.reload.enabling_conditions)
    end

    it 'add validating conditions' do
      visit edit_manage_booking_validation_path(validation, org:)
      within '#validating_conditions' do
        manipulate_conditions
      end
      submit_form
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: '')
      check_conditions(validation.reload.validating_conditions)
    end
  end

  describe 'with BookingQuestion' do
    let(:booking_question) { create(:booking_question, organisation:) }

    it 'add applying conditions' do
      visit edit_manage_booking_question_path(booking_question, org:)
      within '#applying_conditions' do
        manipulate_conditions
      end
      submit_form
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: '')
      check_conditions(booking_question.reload.applying_conditions)
    end
  end

  describe 'on Operatorresponsibility' do
    let(:responsibility) { create(:operator_responsibility, organisation:) }

    it 'add assigning conditions' do
      visit edit_manage_operator_responsibility_path(responsibility, org:)
      within '#assigning_conditions' do
        manipulate_conditions
      end
      submit_form
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: '')
      check_conditions(responsibility.reload.assigning_conditions)
    end
  end

  describe 'on DesignatedDocument' do
    let(:document) { create(:designated_document, organisation:) }

    it 'add attaching conditions' do
      visit edit_manage_designated_document_path(document, org:)
      within '#attaching_conditions' do
        manipulate_conditions
      end
      submit_form
      expect(page).to have_content I18n.t('flash.actions.update.notice', resource_name: '')
      check_conditions(document.reload.attaching_conditions)
    end
  end
end
