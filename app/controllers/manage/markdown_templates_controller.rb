module Manage
  class MarkdownTemplatesController < BaseController
    load_and_authorize_resource :markdown_template

    def index
      respond_with :manage, @markdown_templates
    end

    def show
      respond_with :manage, @markdown_template
    end

    def edit
      respond_with :manage, @markdown_template
    end

    def create
      @markdown_template.organisation = current_organisation
      @markdown_template.save
      respond_with :manage, @markdown_template
    end

    def update
      @markdown_template.update(markdown_template_params)
      respond_with :manage, @markdown_template
    end

    def destroy
      @markdown_template.destroy
      respond_with :manage, @markdown_template, location: manage_markdown_templates_path
    end

    private

    def markdown_template_params
      params.require(:markdown_template).permit(%i[key title locale body])
    end
  end
end
