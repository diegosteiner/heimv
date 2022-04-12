# frozen_string_literal: true

module Manage
  class HomeSerializer < Public::HomeSerializer
    fields :janitor, :address

    view :export do
      fields(*Import::Hash::HomeImporter.used_attributes.map(&:to_sym))
      field :settings do |home|
        home.settings.to_h
      end
      association :tarifs, blueprint: Manage::TarifSerializer, view: :export
    end
  end
end
