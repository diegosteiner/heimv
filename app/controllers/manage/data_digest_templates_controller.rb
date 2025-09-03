# frozen_string_literal: true

module Manage
  class DataDigestTemplatesController < BaseController
    load_and_authorize_resource :data_digest_template

    def index
      @data_digest_templates = @data_digest_templates.where(organisation: current_organisation)
                                                     .order(group: :ASC, label: :ASC, created_at: :DESC)
      respond_with :manage, @data_digest_templates.order(created_at: :ASC)
    end

    def new
      @data_digest_template = DataDigestTemplate.new(data_digest_template_params)
      @data_digest_template.organisation = current_organisation
      respond_with :manage, @data_digest_template
    end

    def edit; end

    def create
      @data_digest_template.organisation = current_organisation
      @data_digest_template.save
      respond_with :manage, @data_digest_template, location: -> { manage_data_digest_templates_path }
    end

    def update
      @data_digest_template.update(data_digest_template_params)
      respond_with :manage, @data_digest_template, location: -> { manage_data_digest_templates_path }
    end

    def destroy
      @data_digest_template.destroy
      respond_with :manage, @data_digest_template, location: -> { manage_data_digest_templates_path }
    end

    private

    def data_digest_template_params
      DataDigestTemplateParams.new(params[:data_digest_template] || params).permitted
    end
  end
end
