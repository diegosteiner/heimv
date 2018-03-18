# frozen_string_literal: true

module ApplicationHelper
  def render_hash_as_dl(hash, model_class = nil)
    content_tag :dl do
      safe_join(hash.map do |key, value|
        content_tag(:dt, model_class&.human_attribute_name(key) || key.to_s) +
          content_tag(:dd, value&.to_s)
      end)
    end
  end
end
