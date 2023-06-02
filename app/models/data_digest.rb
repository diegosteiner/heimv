# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                      :bigint           not null, primary key
#  crunching_finished_at   :datetime
#  crunching_started_at    :datetime
#  data                    :jsonb
#  period_from             :datetime
#  period_to               :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  data_digest_template_id :bigint           not null
#  organisation_id         :bigint           not null
#
# Indexes
#
#  index_data_digests_on_data_digest_template_id  (data_digest_template_id)
#  index_data_digests_on_organisation_id          (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (data_digest_template_id => data_digest_templates.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

require 'csv'

class DataDigest < ApplicationRecord
  Formatter = Struct.new(:default_options, :block)
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

  belongs_to :data_digest_template, inverse_of: :data_digests
  belongs_to :organisation

  delegate :label, to: :data_digest_template
  attr_reader :period

  def self.formatters
    @formatters ||= (superclass.respond_to?(:formatters) && superclass.formatters&.dup) || {}
  end

  def self.formatter(format, default_options: {}, &block)
    formatters[format.to_sym] = Formatter.new(default_options, block)
  end

  def period=(period_key)
    @period = period_key&.to_sym
    period_range = PERIODS[@period]&.call(Time.zone.now)

    self.period_from ||= period_range&.begin
    self.period_to ||= period_range&.end
  end

  def organisation
    super || self.organisation = data_digest_template&.organisation
  end

  def records
    data_digest_template.records(period_from..period_to)
  end

  def crunch
    columns = data_digest_template.columns
    self.data = records.map do |record|
      template_context_cache = {}
      columns.map do |column|
        column.body(record, template_context_cache)
      end
    end
  end

  def crunch!
    update(crunching_started_at: Time.zone.now) &&
      crunch &&
      update(crunching_finished_at: Time.zone.now)
  end

  def crunching_finished?
    crunching_finished_at.present?
  end

  def header
    data_digest_template.columns.map(&:header)
  end

  def footer
    data_digest_template.columns.map(&:footer)
  end

  def format(format, **options)
    data || crunch
    formatter = formatters[format&.to_sym]
    block = formatter&.block
    instance_exec(options, &block) if block.present?
  end

  def formatters
    self.class.formatters
  end

  def localized_period
    I18n.t('data_digests.period_short',
           period_from: (period_from && I18n.l(period_from)) || '',
           period_to: (period_to && I18n.l(period_to)) || '')
  end

  formatter(:csv) do |options = {}|
    options.reverse_merge!({ col_sep: ';', write_headers: true, skip_blanks: true,
                             force_quotes: true, encoding: 'utf-8' })

    CSV.generate(**options) do |csv|
      csv << header
      data&.each { |row| csv << row }
      csv << footer if footer.any?(&:present?)
    end
  end

  formatter(:pdf) do |options = {}|
    options.reverse_merge!({ document_options: { page_layout: :landscape } })
    Export::Pdf::DataDigestPdf.new(self, **options).render_document
  end
end
