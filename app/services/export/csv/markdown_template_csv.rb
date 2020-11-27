module Export
  module Csv 
    class MarkdownTemplateCsv
      def default_options
        { col_sep: ';', write_headers: true, skip_blanks: true, force_quotes: true, encoding: 'utf-8' }
      end


      def export(markdown_templates, options = {})
        CSV.generate(default_options.merge(options)) do |csv| 
          data.each { |row| csv << row }
          # markdown_templates.each do 
        end
      end

      def group_markdown_templates_for_export(markdown_templates)
        markdown_templates.where(home_id: nil).reduce({}) do |groups, markdown_template|
          groups[markdown_template.namespace] ||= {}
          groups[markdown_template.namespace][markdown_template.key] ||= {}
          groups[markdown_template.namespace][markdown_template.key][markdown_template.locale] ||= markdown_template
          groups
        end
      end
    end
  end
end
