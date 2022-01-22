# frozen_string_literal: true

module Manage
  class DesignatedDocumentSerializer < ApplicationSerializer
    fields :designation, :locale, :home_id
    field :file_url do |designated_document|
      url.url_for(designated_document.file)
    end
  end
end
