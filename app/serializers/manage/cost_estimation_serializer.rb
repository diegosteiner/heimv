# frozen_string_literal: true

module Manage
  class CostEstimationSerializer < ApplicationSerializer
    fields :used, :invoiced, :deposited, :per_day, :per_person, :per_person_per_day, :days
  end
end
