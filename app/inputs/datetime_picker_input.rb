class DatetimePickerInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    template.content_tag(:div, class: 'input-group datetime', data: { wrap: true }) do
      template.concat @builder.text_field(attribute_name, input_html_options)
      # template.concat span_remove
      template.concat span_table
    end
  end

  def input_html_options
    super.merge(class: 'form-control', readonly: true, data: { input: true })
  end

  def span_remove
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_remove
    end
  end

  def span_table
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_table
    end
  end

  # rubocop:disable Rails/OutputSafety
  def icon_remove
    "<span class='fa fa-remove' data-close></span>".html_safe
  end

  def icon_table
    "<span class='fa fa-calendar' data-toggle></span>".html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
