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
require 'json'

class DataDigestTemplate < ApplicationRecord
  DEFAULT_COLUMN_CONFIG = [].freeze

  include Subtypeable

  belongs_to :organisation, inverse_of: :data_digest_templates
  has_many :data_digests, inverse_of: :data_digest_template, dependent: :destroy
  validates :label, presence: true
  validates :type, inclusion: { in: ->(_) { DataDigestTemplate.subtypes.keys.map(&:to_s) } }

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

    def replace_in_columns_config!(search, replace, scope: DataDigestTemplate.all)
      scope.where.not(columns_config: nil).find_each do |template|
        json = JSON.generate(template.columns_config).gsub(search, replace)
        template.update!(columns_config: json)
      end
    end
  end

  def group
    super.presence
  end

  def base_scope
    raise NotImplementedError
  end

  def filter(period)
    raise NotImplementedError
  end

  def prefilter
    raise NotImplementedError
  end

  def records(period)
    prefiltered = prefilter&.apply(base_scope) || base_scope
    filter(period)&.apply(prefiltered) || prefiltered
  end

  def columns
    @columns ||= (columns_config || self.class::DEFAULT_COLUMN_CONFIG).map do |config|
      config.symbolize_keys!
      column_type = config.fetch(:type, :default)&.to_sym
      self.class.column_types.fetch(column_type, ColumnType.new).column_from_config(config)
    end
  end

  def columns_config=(value)
    value = JSON.parse(value.presence) if value.is_a?(String)
    value = Array.wrap(value.presence)
    super(value.presence)
  end

  def eject_columns_config
    self.columns_config ||= self.class::DEFAULT_COLUMN_CONFIG
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

    def column_type
      @config.fetch(:type, :default)
    end

    def header
      @header ||= instance_exec(&(@blocks[:header] || -> { @templates[:header]&.render! }))
    end

    def footer
      @footer ||= instance_exec(&(@blocks[:footer] || -> { @templates[:footer]&.render! }))
    end

    def body(record, template_context_cache = {})
      instance_exec(record, template_context_cache, &(@blocks[:body] || -> { @templates[:body]&.render! }))
    end

    def cache_key(record, *parts)
      [column_type, record.class, record.id].concat(parts).join(':')
    end
  end
end
