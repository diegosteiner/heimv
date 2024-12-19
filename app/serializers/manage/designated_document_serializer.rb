# frozen_string_literal: true

module Manage
  class DesignatedDocumentSerializer < ApplicationSerializer
    identifier :id
    fields :designation, :locale, :name, :send_with_accepted, :send_with_contract, :send_with_last_infos
    field :file_url do |designated_document|
      url.url_for(designated_document.file)
    end
  end
end
