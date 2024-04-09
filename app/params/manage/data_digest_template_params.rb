# frozen_string_literal: true

module Manage
  class DataDigestTemplateParams < ApplicationParamsSchema
    define do
      optional(:type).maybe(:string)
      optional(:label).filled(:string)
      optional(:group).maybe(:string)

      raise NotImplemented
      # optional(:columns_config).maybe(:string)
      # + [{ prefilter_params: {} }]
    end
  end
end
