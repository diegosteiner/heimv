# frozen_string_literal: true

module Manage
  class RichTextTemplateSerializer < ApplicationSerializer
    fields :key, :title_i18n, :body_i18n, :home_id

    view :export do
      include_view :default
    end
  end
end
