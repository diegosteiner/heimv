# frozen_string_literal: true

module Manage
  class HomeSerializer < Public::HomeSerializer
    fields :janitor, :address
    field :settings do |home|
      home.settings.to_h
    end

    view :export do
      include_view :default
    end
  end
end
