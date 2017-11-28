class CrudController < ApplicationController
  class_attribute :crud_model

  before_action :authenticate_user!
  before_action :set_breadcrumbs
  # after_action :verify_authorized

  load_and_authorize_resource

  # rubocop:disable Metrics/AbcSize
  def set_crud_breadcrumbs(index_path, model_instance)
    breadcrumbs.add self.class.crud_model.model_name.human(count: :other), index_path

    case params[:action].to_sym
    when :new
      breadcrumbs.add t('new')
    when :show
      breadcrumbs.add model_instance.to_s
    when :edit
      breadcrumbs.add model_instance.to_s, url_for(model_instance)
      breadcrumbs.add t('edit')
    end
  end
  # rubocop:enable Metrics/AbcSize
end
