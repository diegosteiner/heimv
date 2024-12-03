# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digest_templates
#
#  id               :bigint           not null, primary key
#  columns_config   :jsonb
#  group            :string
#  label            :string
#  prefilter_params :jsonb
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_data_digest_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module DataDigestTemplates
  class Tabular < DataDigestTemplate
    DEFAULT_COLUMN_CONFIG = [].freeze

    class << self
      def column_types
        @column_types ||= (superclass.respond_to?(:column_types) && superclass.column_types&.dup) || {}
      end

      def column_type(name, column_type = nil, &)
        column_types[name] = column_type || ColumnType.new(&)
      end

      def replace_in_columns_config!(search, replace, scope: DataDigestTemplate.all)
        scope.where.not(columns_config: nil).find_each do |template|
          json = JSON.generate(template.columns_config).gsub(search, replace)
          template.update!(columns_config: json)
        end
      end
    end

    def columns
      @columns ||= (columns_config.presence || self.class::DEFAULT_COLUMN_CONFIG).map do |config|
        config.symbolize_keys!
        column_type = config.fetch(:type, :default)&.to_sym
        self.class.column_types.fetch(column_type, ColumnType.new).column_from_config(config)
      end
    end

    def columns_config=(value)
      value = value.presence
      value = JSON.parse(value) if value.is_a?(String)
      value = Array.wrap(value)
      value = nil if value == self.class::DEFAULT_COLUMN_CONFIG
      super
    end

    def crunch(records)
      record_ids = records.pluck(:id).uniq
      base_scope.where(id: record_ids).find_each(cursor: record_order.keys, order: record_order.values).map do |record|
        template_context_cache = {}
        columns.map { |column| column.body(record, template_context_cache) }
      end
    end

    def record_order
      { id: :asc }
    end

    def header
      columns.map(&:header)
    end

    def footer
      columns.map(&:footer)
    end

    def eject_columns_config
      self.columns_config = self.class::DEFAULT_COLUMN_CONFIG if columns_config.blank?
    end

    class ColumnType
      def initialize(&)
        instance_exec(&) if block_given?
      end

      def header(&block)
        @header = block
      end

      def footer(&block)
        @footer = block
      end

      def body(&block)
        @body = block
      end

      def column_from_config(config)
        Column.new(config, header: @header, footer: @footer, body: @body)
      end
    end

    class Column
      attr_accessor :config

      def initialize(config, header: nil, footer: nil, body: nil)
        @config = config.symbolize_keys
        @blocks = { header:, footer:, body: }
        @templates = @config.slice(*@blocks.keys).transform_values { |template| Liquid::Template.parse(template) }
      end

      def column_type
        @config.fetch(:type, :default)
      end

      def header
        @header ||= instance_exec(&@blocks[:header] || -> { @templates[:header]&.render! })
      end

      def footer
        @footer ||= instance_exec(&@blocks[:footer] || -> { @templates[:footer]&.render! })
      end

      def body(record, template_context_cache = {})
        instance_exec(record, template_context_cache, &@blocks[:body] ||
          ->(_record, _template_context_cache) { @templates[:body]&.render! })
      end

      def cache_key(record, *parts)
        [column_type, record.class, record.try(:id) || record.object_id].concat(parts).join(':')
      end
    end

    formatter(:csv) do |options = {}|
      require 'csv'
      options.reverse_merge!({ col_sep: ';', write_headers: true, skip_blanks: true,
                               force_quotes: true, encoding: 'utf-8' })

      bom = "\uFEFF"
      bom + CSV.generate(**options) do |csv|
        csv << data_digest_template.header
        data&.each { |row| csv << row }
        csv << data_digest_template.footer if data_digest_template.footer.any?(&:present?)
      end
    end

    formatter(:pdf) do |options = {}|
      options.reverse_merge!({ document_options: { page_layout: :landscape } })
      Export::Pdf::DataDigestPdf.new(self, **options).render_document
    end
  end
end
