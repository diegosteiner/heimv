# frozen_string_literal: true

module Manage
  class DesignatedDocumentsController < BaseController
    load_and_authorize_resource :home
    load_and_authorize_resource :designated_document, through: :home, shallow: true

    def index
      @designated_documents = @designated_documents.where(organisation: current_organisation, home: @home)
      respond_with :manage, @designated_documents
    end

    def new
      @designated_document.home = @home
      @designated_document.assign_attributes(designated_document_params) if designated_document_params
      respond_with :manage, @designated_document
    end

    def edit
      respond_with :manage, @designated_document
    end

    def create
      @designated_document.assign_attributes(organisation: current_organisation)
      @designated_document.update(designated_document_params)
      respond_with :manage, @designated_document, location: return_to_path
    end

    def update
      @designated_document.update(designated_document_params)
      respond_with :manage, @designated_document, location: return_to_path
    end

    def destroy
      @designated_document.destroy
      respond_with :manage, @designated_document, location: return_to_path
    end

    private

    def return_to_path
      return manage_home_designated_documents_path(@designated_document.home) if @designated_document.home.present?

      manage_designated_documents_path
    end

    def designated_document_params
      params[:designated_document]&.permit(:designation, :file, :locale, :remarks, :home_id)
    end
  end
end