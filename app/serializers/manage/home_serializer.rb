# frozen_string_literal: true

module Manage
  class HomeSerializer < Public::HomeSerializer
    fields :janitor, :address, :min_occupation

    view :export do
      fields(*Import::Hash::HomeImporter.used_attributes.map(&:to_sym))
      association :tarifs, blueprint: Manage::TarifSerializer, view: :export
    end
  end
end
