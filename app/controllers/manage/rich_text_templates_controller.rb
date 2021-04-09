# frozen_string_literal: true

module Manage
  class RichTextTemplatesController < BaseController
    load_and_authorize_resource :rich_text_template
    respond_to :json

    def index
      @rich_text_templates = @rich_text_templates.where(organisation: current_organisation)
      @rich_text_templates = @rich_text_templates.order(key: :ASC)
      @rich_text_templates = @rich_text_templates.where(home_id: params[:home_id]) if params[:home_id]
    end

    def show
      respond_with :manage, @rich_text_template
    end

    def new
      dup = current_organisation.rich_text_templates.accessible_by(current_ability).find(params[:dup]) if params[:dup]
      @rich_text_template = dup&.dup
      respond_with :manage, @rich_text_template
    end

    def edit
      respond_with :manage, @rich_text_template
    end

    def create
      @rich_text_template.organisation = current_organisation
      @rich_text_template.save
      respond_with :manage, @rich_text_template
    end

    def update
      @rich_text_template.update(rich_text_template_params)
      respond_with :manage, @rich_text_template, location: manage_rich_text_templates_path
    end

    def destroy
      @rich_text_template.destroy
      respond_with :manage, @rich_text_template, location: manage_rich_text_templates_path
    end

    private

    def rich_text_template_params
      params.require(:rich_text_template).permit(%i[key home_id] +
        I18n.available_locales.map { |l| ["title_#{l}", "body_#{l}"] }.flatten)
    end
  end
end
