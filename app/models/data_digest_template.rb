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
  Formatter = Struct.new(:default_options, :block)

  include Subtypeable
  include TemplateRenderable

  belongs_to :organisation, inverse_of: :data_digest_templates
  has_many :data_digests, inverse_of: :data_digest_template, dependent: :destroy
  validates :label, presence: true
  validates :type, inclusion: { in: ->(_) { DataDigestTemplate.subtypes.keys.map(&:to_s) } }

  class << self
    def period(period_sym, at: Time.zone.now)
      PERIODS[period_sym&.to_sym]&.call(at)
    end

    def formatters
      @formatters ||= (superclass.respond_to?(:formatters) && superclass.formatters&.dup) || {}
    end

    def formatter(format, default_options: {}, &block)
      formatters[format.to_sym] = Formatter.new(default_options, block)
    end
  end

  def group
    super.presence
  end

  def records(period)
    prefiltered = prefilter&.apply(base_scope) || base_scope
    periodfilter(period)&.apply(prefiltered) || prefiltered
  end

  def digest(period = nil)
    DataDigest.new(data_digest_template: self, period:)
  end

  def filter_class; end
  def base_scope; end
  def periodfilter(_period); end
  def crunch(_records); end

  def prefilter
    @prefilter ||= filter_class&.new(prefilter_params.presence || {})
  end
end
