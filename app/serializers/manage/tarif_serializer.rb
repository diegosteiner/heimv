# frozen_string_literal: true

module Manage
  class TarifSerializer < ApplicationSerializer
    view :export do
      # fields(*Import::Hash::TarifImporter.used_attributes.map(&:to_sym))
    end
  end
end
