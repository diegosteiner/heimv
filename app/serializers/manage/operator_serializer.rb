# frozen_string_literal: true

module Manage
  class OperatorSerializer < ApplicationSerializer
    identifier :id
    fields :name, :email, :contact_info
  end
end
