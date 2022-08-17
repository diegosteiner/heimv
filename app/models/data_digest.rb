# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  columns_config     :jsonb
#  data_digest_params :jsonb
#  label              :string
#  prefilter_params   :jsonb
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_data_digests_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'csv'

class DataDigest < ApplicationRecord
  DEFAULT_COLUMN_CONFIG = [].freeze
  PERIODS = {
    ever: ->(_at) { Range.new(nil, nil) },
    last_year: ->(at) { ((at - 1.year).beginning_of_year)..((at - 1.year).end_of_year) },
    last_12_months: ->(at) { (at - 12.months)..at },
    last_6_months: ->(at) { (at - 6.months)..at },
    last_3_months: ->(at) { (at - 3.months)..at },
    last_month: ->(at) { ((at - 1.month).beginning_of_month)..((at - 1.month).end_of_month) },
    this_year: ->(at) { (at.beginning_of_year)..(at.end_of_year) },
    this_month: ->(at) { (at.beginning_of_month)..(at.end_of_month) },
    this_week: ->(at) { (at.beginning_of_week)..(at.end_of_week) },
    today: ->(at) { (at.beginning_of_day)..(at.end_of_day) },
    next_30_days: ->(at) { (at.beginning_of_day)..((at + 30.days).end_of_day) },
    next_month: ->(at) { ((at + 1.month).beginning_of_month)..((at + 1.month).end_of_month) },
    next_3_months: ->(at) { at..(at + 3.months) },
    next_6_months: ->(at) { at..(at + 6.months) },
    next_12_months: ->(at) { at..(at + 12.months) },
    next_year: ->(at) { ((at + 1.year).beginning_of_year)..((at + 1.year).end_of_year) },
    until_now: ->(at) { nil..at },
    from_now: ->(at) { at..nil }
  }.freeze

  include Subtypeable

  belongs_to :organisation
  validates :label, presence: true

  class << self
    def column_types
      @column_types ||= (superclass.respond_to?(:column_types) && superclass.column_types&.dup) || {}
    end

    def column_type(name, column_type = nil, &block)
      column_types[name] = column_type || ColumnType.new(&block)
    end

    def period(period_sym, at: Time.zone.now)
      PERIODS[period_sym&.to_sym]&.call(at)
    end
  end

  def evaluate(period)
    PeriodicData.new(self, period, columns, filter(period).apply(base_scope))
  end

  def base_scope
    raise NotImplementedError
  end

  def filter(period)
    raise NotImplementedError
  end

  def columns
    @columns ||= (columns_config || self.class::DEFAULT_COLUMN_CONFIG).map do |config|
      config.symbolize_keys!
      column_type = config.fetch(:type, :default)&.to_sym
      self.class.column_types.fetch(column_type, ColumnType.new).column_from_config(config)
    end
  end

  def columns_config=(value)
    value = value.presence
    value = JSON.parse(value) if value.is_a?(String)
    value = Array.wrap(value)
    super(value.presence)
  end

  class ColumnType
    def initialize(&block)
      instance_exec(&block) if block_given?
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
      @blocks = { header: header, footer: footer, body: body }
      @templates = @config.slice(*@blocks.keys).transform_values { |template| Liquid::Template.parse(template) }
    end

    def header
      @header ||= instance_exec(&(@blocks[:header] || -> { @templates[:header]&.render! }))
    end

    def footer
      @footer ||= instance_exec(&(@blocks[:footer] || -> { @templates[:footer]&.render! }))
    end

    def body(record)
      instance_exec(record, &(@blocks[:body] || -> { @templates[:body]&.render! }))
    end
  end

  class PeriodicData
    Formatter = Struct.new(:default_options, :block)
    attr_reader :data_digest, :period, :columns, :data

    class << self
      def formatters
        @formatters ||= (superclass.respond_to?(:formatters) && superclass.formatters&.dup) || {}
      end

      def formatter(format, default_options: {}, &block)
        formatters[format.to_sym] = Formatter.new(default_options, block)
      end
    end

    def initialize(data_digest, period, columns, data)
      @data_digest = data_digest
      @period = period
      @columns = columns
      @data = data
    end

    def format(format, **options)
      formatter = formatters[format&.to_sym]
      block = formatter&.block
      instance_exec(options, &block) if block.present?
    end

    def formatters
      self.class.formatters
    end

    def header
      columns.map(&:header)
    end

    def footer
      columns.map(&:footer)
    end

    def rows
      @rows ||= data.map do |row|
        columns.map { |column| column.body(row) }
      end
    end

    formatter(:csv) do |options = {}|
      options.reverse_merge!({ col_sep: ';', write_headers: true, skip_blanks: true,
                               force_quotes: true, encoding: 'utf-8' })

      CSV.generate(**options) do |csv|
        csv << header
        rows.each { |row| csv << row }
        csv << footer if footer.any?(&:present?)
      end
    end

    formatter(:pdf) do |options = {}|
      options.reverse_merge!({ document_options: { page_layout: :landscape } })
      Export::Pdf::DataDigestPeriodPdf.new(self, **options).render_document
    end
  end
end
