module Manage
  class BookingReportParams < ApplicationParams
    def self.permitted_keys
      %i[type label] + [{ tarif_ids: [], filter_params: {} }]
    end

    def self.sanitize(params)
      params.merge(filter_params: BookingFilterParams.sanitize(params.delete(:filter_params) || {}))
    end
  end
end
