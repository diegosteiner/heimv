# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
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
  Formatter = Struct.new(:default_options, :block)
  PeriodicData = Struct.new(:data_digest, :period, :header, :footer, :data)

  belongs_to :organisation
  validates :label, presence: true

  def self.formatters
    @formatters ||= superclass.respond_to?(:formatters) && superclass.formatters&.dup || {}
  end

  def self.periods
    @periods ||= superclass.respond_to?(:periods) && superclass.periods&.dup || {}
  end

  def self.formatter(format, default_options: {}, &block)
    formatters[format.to_sym] = Formatter.new(default_options, block)
  end

  def self.register_period(**new_periods)
    periods.merge!(new_periods)
  end

  formatter(:csv) do |periodic_data, options|
    options.reverse_merge!({ col_sep: ';', write_headers: true, skip_blanks: true,
                             force_quotes: true, encoding: 'utf-8' })

    CSV.generate(options) do |csv|
      csv << periodic_data.header
      periodic_data.data.each { |row| csv << row }
      csv << periodic_data.footer if periodic_data.footer.present?
    end
  end

  formatter(:pdf) do |periodic_data, options|
    options.reverse_merge!({ document_options: { page_layout: :landscape } })
    Export::Pdf::DataDigestPeriodPdf.new(periodic_data, options).render_document
  end

  register_period ever: ->(_at) { Range.new(nil, nil) },
                  this_year: ->(at) { (at.beginning_of_year)..(at.end_of_year) },
                  last_year: ->(at) { ((at - 1.year).beginning_of_year)..((at - 1.year).end_of_year) },
                  last_12_months: ->(at) { (at - 12.months)..at },
                  last_6_months: ->(at) { (at - 6.months)..at },
                  last_3_months: ->(at) { (at - 3.months)..at },
                  last_month: ->(at) { (at - 1.month)..at },
                  next_month: ->(at) { at..(at + 1.month) },
                  next_3_months: ->(at) { at..(at + 3.months) },
                  next_6_months: ->(at) { at..(at + 6.months) },
                  next_12_months: ->(at) { at..(at + 12.months) },
                  next_year: ->(at) { ((at + 1.year).beginning_of_year)..((at + 1.year).end_of_year) },
                  until_now: ->(at) { nil..at },
                  from_now: ->(at) { at..nil }

  def digest(period, format: nil, **options)
    return unless period.is_a?(Range)

    periodic_data = PeriodicData.new(self, period, build_header(period, options),
                                     build_footer(period, options),
                                     build_data(period, options))
    formatter = self.class.formatters[format&.to_sym]
    return periodic_data unless formatter

    formatter.block.call(periodic_data, options.fetch(:format_options, {}))
  end

  def period(period_sym, at: Time.zone.now)
    self.class.periods[period_sym&.to_sym]&.call(at)
  end

  def scope
    []
  end

  protected

  def prefilter; end

  def build_header(_period, _options)
    []
  end

  def build_data(_period, _options); end

  def build_footer(_period, _options)
    nil
  end
end
