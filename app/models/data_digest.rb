# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  data_digest_params :jsonb
#  filter_params      :jsonb
#  label              :string
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
  belongs_to :organisation

  validates :label, presence: true

  def filter; end

  def periodic_data(period = (1.year.ago)..(1.year.from_now))
    self.class::Period.new(self, period)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def periods(at = Time.zone.now.end_of_day)
    {
      ever: Range.new(nil, nil),
      this_year: (at.beginning_of_year)..(at.end_of_year),
      last_year: ((at - 1.year).beginning_of_year)..((at - 1.year).end_of_year),
      last_12_months: (at - 12.months)..at,
      last_6_months: (at - 6.months)..at,
      last_3_months: (at - 3.months)..at,
      last_month: (at - 1.month)..at,
      next_month: at..(at + 1.month),
      next_3_months: at..(at + 3.months),
      next_6_months: at..(at + 6.months),
      next_12_months: at..(at + 12.months),
      next_year: ((at + 1.year).beginning_of_year)..((at + 1.year).end_of_year),
      until_now: nil..at,
      from_now: at..nil
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  class Period
    attr_reader :data_digest, :period_range

    def self.formatters
      @formatters ||= superclass.respond_to?(:formatters) && superclass.formatters&.dup || {}
    end

    def formatters
      self.class.formatters
    end

    def default_formatter_options
      {
        pdf: {
          document_options: { page_layout: :landscape }
        },
        csv: {
          col_sep: ';', write_headers: true, skip_blanks: true,
          force_quotes: true, encoding: 'utf-8'
        }
      }
    end

    def format(format, options = {})
      options = options.reverse_merge(default_formatter_options[format] || {})
      self.class.formatters[format].call(self, options)
    end

    def self.formatter(format, &block)
      formatters[format.to_sym] = block
    end

    formatter :csv do |data_digest_period, options|
      CSV.generate(options) { |csv| data_digest_period.data.each { |row| csv << row } }
    end

    formatter :pdf do |data_digest_period, options|
      Export::Pdf::DataDigestPeriodPdf.new(data_digest_period, options).render_document
    end

    def data
      @data ||= filtered.map { |record| data_row(record) }
    end

    def initialize(data_digest, period_range)
      @period_range = period_range
      @data_digest = data_digest
    end

    def filtered
      []
    end

    def data_header; end

    def data_footer; end

    def data_row(record); end
  end
end
