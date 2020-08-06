# frozen_string_literal: true

module Admin
  class ImportsController < BaseController
    load_and_authorize_resource :organisation
    before_action :set_organisation

    def show
      respond_to do |format|
        format.json { render json: JSON.generate(Import::OrganisationImporter.new(@organisation).export) }
      end
    end

    def new; end

    def create
      import_data = JSON.parse(params[:import_data])
      import_options = { replace: params[:replace] }
      imported = Import::OrganisationImporter.new(@organisation, import_options).import(import_data)

      if imported
        # TODO: translate
        redirect_to edit_manage_organisation_path, notice: 'Import succeeded'
      else
        # TODO: translate
        redirect_to new_admin_import_path, alert: 'Import failed'
      end
    end

    private

    def set_organisation
      @organisation = current_organisation
    end
  end
end
