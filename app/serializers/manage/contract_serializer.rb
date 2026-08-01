# frozen_string_literal: true

module Manage
  class ContractSerializer < ApplicationSerializer
    identifier :id
    fields :sent_at, :tenant_signed_at, :confirmed_at, :locale
  end
end
