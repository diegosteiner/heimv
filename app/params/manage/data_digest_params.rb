# frozen_string_literal: true

module Manage
  class DataDigestParams < ApplicationParams
    def self.permitted_keys
      %i[type label columns_config] + [{ tarif_ids: [], prefilter_params: {} }]
    end
  end
end
