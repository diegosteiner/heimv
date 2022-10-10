# frozen_string_literal: true

module Manage
  class HomeSerializer < Public::HomeSerializer
    fields :janitor, :address

    view :export do
      field :requests_allowed

      include_view :default
    end
  end
end
