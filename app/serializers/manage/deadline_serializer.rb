# frozen_string_literal: true

module Manage
  class DeadlineSerializer < ApplicationSerializer
    fields :at, :postponable_for
  end
end
