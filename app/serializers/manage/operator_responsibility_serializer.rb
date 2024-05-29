# frozen_string_literal: true

module Manage
  class OperatorResponsibilitySerializer < ApplicationSerializer
    association :operator, blueprint: Manage::OperatorSerializer

    fields :booking_id, :responsibility, :remarks
  end
end
