class PagesController < ApplicationController
  def home; end

  def about; end

  def ext
    respond_to do |format|
      format.js render file: helpers.asset_pack_path('ext')
    end
  end
end
