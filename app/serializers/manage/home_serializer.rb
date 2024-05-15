# frozen_string_literal: true

module Manage
  class HomeSerializer < Public::HomeSerializer
    fields :janitor, :description

    view :export do
      fields :discarded_at, :occupiable, :home_id

      include_view :default
    end
  end
end
