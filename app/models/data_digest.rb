# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  columns            :jsonb
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
  include Subtypeable

  belongs_to :organisation
  validates :label, presence: true

  attribute :columns, :json

  class << self
    def periods(**new_periods)
      @periods ||= (superclass.respond_to?(:periods) && superclass.periods&.dup) || {}
      @periods.merge!(new_periods)
      @periods
    end
end

  periods ever: ->(_at) { Range.new(nil, nil) },
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

  def digest(period)
    return unless period.is_a?(Range)

    PeriodicData.new(self, period, 
      columns.map { |column| column_header(column) }, 
      columns.map { |column| column_footer(column) }, 
      data_of_period(period).map do |data|
        columns.map { |column| column_data(column, data) } 
      end
    )
  end

  def period(period_sym, at: Time.zone.now)
    self.class.periods[period_sym&.to_sym]&.call(at)
  end

  def data_of_period(period)
    base_scope
      .then { |data| prefilter.apply(data) }
      .then { |data| period_filter(period).apply(data) }
  end

  def base_scope; end

  def prefilter; end

  def columns
    super.presence || self.class.default_columns
  end

  protected

  def column_header(column)
    header = column[:header]
    header && Liquid::Template.parse(header).render!
  end

  def column_footer(column)
  end

  def column_data(column, subject)
  end

  class PeriodicData
    Formatter = Struct.new(:default_options, :block)
    attr_reader :data_digest, :period, :header, :footer, :data

    class << self
      def formatters
        @formatters ||= (superclass.respond_to?(:formatters) && superclass.formatters&.dup) || {}
      end

      def formatter(format, default_options: {}, &block)
        formatters[format.to_sym] = Formatter.new(default_options, block)
      end
    end

    def initialize(data_digest, period, header, footer, data)
      @data_digest = data_digest
      @period = period
      @header = header
      @footer = footer
      @data = data
    end

    def format(format, **options)
      formatter = formatters[format&.to_sym]
      formatter&.block&.call(self, **options)
    end

    def formatters
      self.class.formatters
    end

    formatter(:csv) do |periodic_data, options = {}|
      options.reverse_merge!({ col_sep: ';', write_headers: true, skip_blanks: true,
                               force_quotes: true, encoding: 'utf-8' })

      CSV.generate(**options) do |csv|
        csv << periodic_data.header
        periodic_data.data.each { |row| csv << row }
        csv << periodic_data.footer if periodic_data.footer.present?
      end
    end

    formatter(:pdf) do |periodic_data, options = {}|
      options.reverse_merge!({ document_options: { page_layout: :landscape } })
      Export::Pdf::DataDigestPeriodPdf.new(periodic_data, **options).render_document
    end
  end
end
