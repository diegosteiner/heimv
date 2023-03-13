# frozen_string_literal: true

module Manage
  class HomeSerializer < Public::HomeSerializer
    fields :janitor, :description

    view :export do
      fields :active, :occupiable, :home_id

      include_view :default
    end
  end
end
