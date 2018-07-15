module Manage
  class HomeParams < ApplicationParams
    def self.permitted_keys
      [:name, :ref, :house_rules, :janitor,
       tarifs_attributes: TarifParams.permitted_keys + [:id]]
    end
  end
end
