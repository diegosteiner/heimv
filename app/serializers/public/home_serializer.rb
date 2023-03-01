# frozen_string_literal: true

module Public
  class HomeSerializer < ApplicationSerializer
    fields :id, :name, :description
  end
end
