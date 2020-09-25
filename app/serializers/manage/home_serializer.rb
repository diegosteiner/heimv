# frozen_string_literal: true

module Manage
  class HomeSerializer < Public::HomeSerializer
    fields :janitor, :address, :min_occupation
  end
end
