# frozen_string_literal: true

module Manage
  class HomeParams < ApplicationParams
    def self.permitted_keys
      [:name, :ref, :house_rules, :janitor, :address, :requests_allowed, :min_occupation, :booking_margin,
       tarifs_attributes: TarifParams.permitted_keys + [:id]]
    end
  end
end
