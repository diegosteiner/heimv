# frozen_string_literal: true

module Manage
  class NotificationParams < ApplicationParamsSchema
    define do
      optional(:subject).maybe(:string)
      optional(:body).maybe(:string)
      optional(:to).maybe(:string)
    end
  end
end
