module Manage
  class ReportParams < ApplicationParams
    def self.permitted_keys
      %i[type label] + [{ tarif_ids: [], filter_params: {} }]
    end
  end
end
