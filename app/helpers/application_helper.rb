# frozen_string_literal: true

module ApplicationHelper
  def render_hash_as_dl(hash, model_class = nil)
    tag.dl do
      safe_join(hash.map do |key, value|
        tag.dt(model_class&.human_attribute_name(key) || key.to_s) +
          tag.dd(value&.to_s)
      end)
    end
  end

  def type_options_for_select(types_array)
    types_array.map { |type| [type.model_name.human, type] }
  end

  def enum_options_for_select(klass, enum, selected, values = klass.send(enum))
    options_for_select(values.map { |e, _v| [klass.human_enum(enum, e), e] }, selected)
  end

  def css_class(css_map)
    css_map.find_all(&:last).map(&:first).join(' ')
  end
end
