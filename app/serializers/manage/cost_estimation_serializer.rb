# frozen_string_literal: true

module Manage
  class CostEstimationSerializer < ApplicationSerializer
    fields :used, :total, :deposit
  end
end
