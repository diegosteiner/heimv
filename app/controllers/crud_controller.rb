class CrudController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  check_authorization

  def self.breadcrumb(actions = nil, &block)
    before_action(actions, &block)
  end
end
