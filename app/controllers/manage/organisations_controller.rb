# frozen_string_literal: true

module Manage
  class OrganisationsController < BaseController
    load_and_authorize_resource :organisation
    before_action :set_organisation
    after_action :attach_files, only: :update

    def edit; end

    def update
      @organisation.update(organisation_params)
      respond_with :manage, @organisation, location: edit_manage_organisation_path
    end

    def show
      respond_to do |format|
        format.html { redirect_to }
        format.json { render json: JSON.generate(Import::OrganisationImporter.new(@organisation).export) }
      end
    end

    def import
      return if params[:import_data].blank?

      import_data = JSON.parse(params[:import_data])
      if Import::OrganisationImporter.new(@organisation, { replace: params[:replace] }).import(import_data)
        flash[:notice] = t('.success')
      else
        flash[:alert] = t('.error')
      end
    end

    private

    def set_organisation
      @organisation = current_organisation
    end

    def attach_files
      terms_pdf = organisation_params[:terms_pdf]
      logo = organisation_params[:logo]
      privacy_statement_pdf = organisation_params[:privacy_statement_pdf]

      @organisation.terms_pdf.attach(terms_pdf) if terms_pdf.present?
      @organisation.privacy_statement_pdf.attach(privacy_statement_pdf) if privacy_statement_pdf.present?
      @organisation.logo.attach(logo) if logo.present?
    end

    def organisation_params
      return params.require(:organisation).permit(OrganisationParams.admin_permitted_keys) if current_user.role_admin?

      OrganisationParams.new(params[:organisation])
    end
  end
end
