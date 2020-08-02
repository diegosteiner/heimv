# frozen_string_literal: true

module Manage
  class DeadlineSerializer < ApplicationSerializer
    attributes :at, :postponable_for
  end
end
