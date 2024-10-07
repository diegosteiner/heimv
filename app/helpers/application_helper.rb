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

  def subtype_options_for_select(types)
    types.values.map { |type| [type.model_name.human, type] }
  end

  def enum_options_for_select(klass, enum, selected, values = klass.send(enum))
    options_for_select(values.map { |key, _value| [klass.human_enum(enum, key), key] }, selected)
  end

  def salutation_form_options_for_select(tenant)
    # placeholders = {
    #   informal_name: [Tenant.human_attribute_name(:first_name), tenant.organisation.nickname_label]
    #     .compact_blank.join(' / '),
    #   full_name: [Tenant.human_attribute_name(:first_name), Tenant.human_attribute_name(:last_name)]
    #     .compact_blank.join(' '),
    #   last_name: Tenant.human_attribute_name(:last_name)
    # }.transform_values { "<#{_1}>" }
    placeholders = { informal_name: '...', full_name: '...', last_name: '...' }
    values = Tenant.salutation_forms.map do |key, _value|
      [Tenant.human_enum(:salutation_forms, key, **placeholders), key]
    end
    options_for_select(values, tenant&.salutation_form)
  end
end
