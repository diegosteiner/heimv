# frozen_string_literal: true

module Manage
  class OrganisationsController < BaseController
    load_and_authorize_resource :organisation
    before_action :set_organisation

    def show
      respond_to do |format|
        format.html { redirect_to manage_root_path }
        format.json { render json: Manage::OrganisationSerializer.render(@organisation) }
      end
    end

    def edit; end

    def update
      @organisation.smtp_settings ||= SmtpSettings.new
      @organisation.smtp_settings.assign_attributes(smtp_settings_params) if smtp_settings_params.present?
      @organisation.update(organisation_params)
      respond_with :manage, @organisation, location: -> { edit_manage_organisation_path }
    end

    private

    def set_organisation
      @organisation = current_organisation
    end

    def organisation_params
      if current_user.role_admin?
        params.expect(organisation: OrganisationParams.admin_permitted_keys)
      else
        OrganisationParams.new(params[:organisation]).permitted
      end
    end

    def smtp_settings_params
      permitted = SmtpSettingsParams.new(params.dig(:organisation, :smtp_settings)).permitted
      permitted&.delete(:password) if permitted&.[](:password).blank?
      permitted
    end
  end
end
