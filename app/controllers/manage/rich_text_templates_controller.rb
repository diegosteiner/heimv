# frozen_string_literal: true

module Manage
  class RichTextTemplatesController < BaseController
    load_and_authorize_resource :rich_text_template
    respond_to :json
    helper_method :rich_text_template_group

    def index
      @rich_text_templates = @rich_text_templates.ordered.includes(:home).where(organisation: current_organisation)
      @rich_text_templates = @rich_text_templates.where(home_id: params[:home_id]) if params[:home_id]
      @rich_text_templates = @rich_text_templates.where(key: params[:key]) if params[:key]
    end

    def show
      respond_with :manage, @rich_text_template
    end

    def new
      dup = current_organisation.rich_text_templates.accessible_by(current_ability).find(params[:dup]) if params[:dup]
      @rich_text_template = dup&.dup || RichTextTemplate.new
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
      respond_with :manage, @rich_text_template
    end

    def destroy
      @rich_text_template.destroy
      respond_with :manage, @rich_text_template, location: manage_rich_text_templates_path
    end

    private

    def rich_text_template_params
      RichTextTemplateParams.new(params.require(:rich_text_template)).permitted
    end

    def rich_text_template_group(rich_text_template)
      key = rich_text_template.key.to_s
      return :manage_notifications if key.starts_with?('manage_')

      if key.ends_with?('_notification')
        return :booking_agent_notifications if key.include?('booking_agent')

        return :tenant_notifications
      end
      return :document_text if rich_text_template.key.to_s.ends_with?('_text')
    end
  end
end
