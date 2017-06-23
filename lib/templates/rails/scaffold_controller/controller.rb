<% if namespaced? -%>
require_dependency "<%= namespaced_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action :set_<%= singular_table_name %>, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>
    authorize <%= class_name %>
  end

  def show
    breadcrumbs.add @<%= singular_table_name %>.to_s
  end

  def new
    authorize <%= class_name %>
    breadcrumbs.add t('new')
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
  end

  def edit
    breadcrumbs.add @<%= singular_table_name %>.to_s, <%= singular_table_name %>_path(@<%= singular_table_name %>)
    breadcrumbs.add t('edit')
  end

  def create
    authorize <%= class_name %>
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>

    if @<%= orm_instance.save %>
      redirect_to @<%= singular_table_name %>, notice: t('actions.create.success', model_name: <%= class_name %>.model_name.human)
    else
      render :new
    end
  end

  def update
    if @<%= orm_instance.update("#{singular_table_name}_params") %>
      redirect_to @<%= singular_table_name %>, notice: t('actions.update.success', model_name: <%= class_name %>.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @<%= orm_instance.destroy %>
    redirect_to <%= index_helper %>_path, notice: t('actions.destroy.success', model_name: <%= class_name %>.model_name.human)
  end

  private
    def set_<%= singular_table_name %>
      @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
      authorize @<%= singular_table_name %>
    end

    def set_breadcrumbs
      super
      breadcrumbs.add <%= class_name %>.model_name.human(count: :other), <%= index_helper %>_path
    end

    def <%= "#{singular_table_name}_params" %>
      <%- if attributes_names.empty? -%>
      params.fetch(:<%= singular_table_name %>, {})
      <%- else -%>
      params.require(:<%= singular_table_name %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
      <%- end -%>
    end
end
<% end -%>
