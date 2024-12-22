# frozen_string_literal: true

module Manage
  class RichTextTemplateSerializer < ApplicationSerializer
    identifier :id
    fields :key, :title_i18n, :body_i18n

    view :export do
      include_view :default
    end
  end
end
