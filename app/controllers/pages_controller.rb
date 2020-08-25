# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    redirect_to(manage_dashboard_path(org: current_organisation&.slug))
  end

  def ext
    respond_to do |format|
      format.js render file: helpers.asset_pack_path('ext')
    end
  end
end
