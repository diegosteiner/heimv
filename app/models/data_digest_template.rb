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

class DataDigestTemplate < ApplicationRecord
  DEFAULT_COLUMN_CONFIG = [].freeze

  include Subtypeable

  belongs_to :organisation
  has_many :data_digests, inverse_of: :data_digest_template, dependent: :destroy
  validates :label, presence: true

  def group
    super.presence
  end

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

  def base_scope
    raise NotImplementedError
  end

  def filter(period)
    raise NotImplementedError
  end

  def records(period)
    filter(period).apply(base_scope)
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
end