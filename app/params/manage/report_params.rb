module Manage
  class ReportParams < ApplicationParams
    def self.permitted_keys
      multi_param paid_at_after: Date, paid_at_before: Date

      %i[type label] + [{ tarif_ids: [], filter_params: {} }]
    end
  end
end
