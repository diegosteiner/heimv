# frozen_string_literal: true

module Manage
  class ContractSerializer < ApplicationSerializer
    identifier :id
    fields :sent_at, :signed_at, :locale
  end
end
