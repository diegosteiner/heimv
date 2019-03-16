# frozen_string_literal: true

module FormHelper
  def calendar_input(form, method, required: false)
    tag('app-calendar-input',
        name: "#{form.object_name}[#{method}]",
        label: form.object.class.human_attribute_name(method),
        value: form.object.try(method)&.iso8601,
        ref: method,
        ':required' => required)
  end
end
