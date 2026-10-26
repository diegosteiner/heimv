# frozen_string_literal: true

module Manage
  class DeadlineSerializer < ApplicationSerializer
    identifier :id
    fields :at, :postponable_for, :armed
    field(:expired) { it.expired? }
  end
end
