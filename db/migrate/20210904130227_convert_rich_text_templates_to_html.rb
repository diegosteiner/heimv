class ConvertRichTextTemplatesToHtml < ActiveRecord::Migration[6.1]
  def up
    add_column :rich_text_templates, :body_i18n_markdown, :jsonb, default: {}
    RichTextTemplate.transaction do
      RichTextTemplate.find_each do 
        _1.body_i18n_markdown = _1.body_i18n
        _1.body_i18n = _1.body_i18n.transform_values { |body| ::Markdown.convert_to_html(body) }
        _1.save!
      end
    end
  end

  def down 
  end
end
