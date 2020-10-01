# frozen_string_literal: true

module Manage
  class MarkdownTemplatesController < BaseController
    load_and_authorize_resource :markdown_template
    respond_to :json

    def index
      @markdown_templates = @markdown_templates.order(key: :ASC)
      @markdown_templates = @markdown_templates.where(namespace: params[:namespace]) if params[:namespace]
      @markdown_templates = @markdown_templates.where(home_id: params[:home_id]) if params[:home_id]
    end

    def show
      respond_with :manage, @markdown_template
    end

    def edit
      respond_with :manage, @markdown_template
    end

    # def create_missing
    #   respond_with :manage, MarkdownTemplate.create_missing(current_organisation),
    #                location: manage_markdown_templates_path
    # end

    def create
      @markdown_template.organisation = current_organisation
      @markdown_template.save
      respond_with :manage, @markdown_template
    end

    def update
      @markdown_template.update(markdown_template_params)
      respond_with :manage, @markdown_template, location: manage_markdown_templates_path
    end

    def destroy
      @markdown_template.destroy
      respond_with :manage, @markdown_template, location: manage_markdown_templates_path
    end

    private

    def markdown_template_params
      params.require(:markdown_template).permit(%i[key title locale body namespace home_id])
    end
  end
end
