# frozen_string_literal: true

module Manage
  class DesignatedDocumentsController < BaseController
    load_and_authorize_resource :designated_document

    def index
      @designated_documents = @designated_documents.where(organisation: current_organisation).order(created_at: :ASC)
      respond_with :manage, @designated_documents
    end

    def new
      @designated_document.assign_attributes(designated_document_params) if designated_document_params
      respond_with :manage, @designated_document
    end

    def edit
      @designated_document.attaching_conditions.build
      respond_with :manage, @designated_document
    end

    def create
      @designated_document.assign_attributes(organisation: current_organisation)
      @designated_document.update(designated_document_params)
      respond_with :manage, @designated_document, location: manage_designated_documents_path
    end

    def update
      @designated_document.update(designated_document_params)
      respond_with :manage, @designated_document, location: manage_designated_documents_path
    end

    def destroy
      @designated_document.destroy
      respond_with :manage, @designated_document, location: manage_designated_documents_path
    end

    private

    def designated_document_params
      params[:designated_document]&.permit(:designation, :file, :locale, :remarks, :name,
                                           :send_with_contract, :send_with_last_infos,
                                           attaching_conditions_attributes: BookingConditionParams.permitted_keys +
                                             %i[id _destroy])
    end
  end
end
