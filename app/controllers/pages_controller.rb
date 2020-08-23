# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    redirect_to(manage_dashboard_path(org: current_user.organisation.slug)) if current_user&.organisation&.present?
  end

  def ext
    respond_to do |format|
      format.js render file: helpers.asset_pack_path('ext')
    end
  end
end
