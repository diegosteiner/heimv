# frozen_string_literal: true

class PagesController < ApplicationController
  def ext
    respond_to do |format|
      format.js render file: helpers.asset_pack_path('ext')
    end
  end
end
