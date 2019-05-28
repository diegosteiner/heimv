module Manage
  class HomeParams < ApplicationParams
    def self.permitted_keys
      [:name, :ref, :house_rules, :janitor, :place, :requests_allowed,
       tarifs_attributes: TarifParams.permitted_keys + [:id]]
    end
  end
end
