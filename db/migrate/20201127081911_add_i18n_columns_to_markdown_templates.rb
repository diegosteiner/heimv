class AddI18nColumnsToMarkdownTemplates < ActiveRecord::Migration[6.0]
  def change
    rename_column :markdown_templates, :title, :original_title
    rename_column :markdown_templates, :body, :original_body
    add_column :markdown_templates, :title_i18n, :jsonb, default: {}
    add_column :markdown_templates, :body_i18n, :jsonb, default: {}
    reversible do |direction|
      direction.up { merge_markdown_templates_with_locale }
    end
    remove_column :markdown_templates, :original_title, :stirng
    remove_column :markdown_templates, :original_body, :string
    remove_column :markdown_templates, :locale, :string
  end

  protected

  def merge_markdown_templates_with_locale
    MarkdownTemplate.transaction do
      MarkdownTemplate.find_each do |markdown_template|
        equals = MarkdownTemplate.where(organisation: markdown_template.organisation, 
                                        namespace: markdown_template.namespace,
                                        home: markdown_template.home,
                                        key: markdown_template.key)

        markdown_template.title_i18n = equals.index_by(&:locale).transform_values(&:original_title)
        markdown_template.body_i18n = equals.index_by(&:locale).transform_values(&:original_body)
        markdown_template.save && equals.where.not(id: markdown_template.id).destroy_all
      end
    end
  end
end
