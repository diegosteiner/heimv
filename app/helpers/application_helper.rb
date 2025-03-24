# frozen_string_literal: true

module ApplicationHelper
  def react_component(path, props, **)
    full_path = Rails.root.join('app/javascript/components/rails', "#{path}.tsx")
    raise ArgumentError, 'Component does not exist' unless full_path.exist?

    tag.div(data: { component: path, props: }, **) do
      tag.div(class: 'd-flex justify-content-center align-items-center p-4 my-auto') do
        tag.span(class: 'spinner-border text-secondary', role: 'status')
      end
    end
  end

  def lines_as_paragraphs(lines)
    safe_join(lines.presence&.lines&.map { |line| tag.p(line) })
  end

  def render_hash_as_dl(hash, model_class = nil)
    tag.dl do
      safe_join(hash.map do |key, value|
        tag.dt(model_class&.human_attribute_name(key) || key.to_s) +
          tag.dd(value&.to_s)
      end)
    end
  end

  def render_partial_or_default(partial, locals: {}, &)
    if lookup_context.template_exists?(partial, [], true)
      render partial:, locals:
    else
      capture(&)
    end
  end

  def subtype_options_for_select(types)
    types.values.map { |type| [type.model_name.human, type] }
  end

  def enum_options_for_select(klass, enum, selected, values = klass.send(enum))
    options_for_select(values.map { |key, _value| [klass.human_enum(enum, key), key] }, selected)
  end

  def salutation_form_options_for_select(selected)
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
    options_for_select(values, selected)
  end
end
