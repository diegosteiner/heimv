class RemoveNamespaceFromMarkdownTemplates < ActiveRecord::Migration[6.0]
  def change
    reversible do |direction|
      direction.up do 
        MarkdownTemplate.find_each do |markdown_template|
          markdown_template.update(
            key: [markdown_template.key, markdown_template.namespace.presence].compact.join('_')
          )
        end
      end
    end

    remove_column :markdown_templates, :namespace, :string
    add_index :markdown_templates, %i[key home_id organisation_id], unique: true
    MarkdownTemplate.reset_column_information
  end
end
