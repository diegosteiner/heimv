# frozen_string_literal: true

module Manage
  class DataDigestTemplateParams < ApplicationParams
    def self.permitted_keys
      %i[type label group columns_config] + [{ prefilter_params: {} }]
    end
  end
end
