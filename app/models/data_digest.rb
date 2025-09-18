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

class DataDigest < ApplicationRecord
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
    from_now: ->(at) { at..nil },
    last_and_next_12_months: ->(at) { (at - 12.months)..(at + 12.months) }
  }.freeze

  belongs_to :data_digest_template, inverse_of: :data_digests
  belongs_to :organisation

  attr_reader :period

  def period=(period_key)
    @period = period_key&.to_sym
    period_range = PERIODS[@period]&.call(Time.zone.now)

    self.period_from ||= period_range&.begin
    self.period_to ||= period_range&.end
  end

  def label
    return data_digest_template.label if period_from.blank? && period_to.blank?

    [data_digest_template.label, [period_from, period_to].map do
      it ? I18n.l(it, format: :short) : ''
    end.join('-')].join(' ')
  end

  def period_from=(value)
    value = value.presence
    value = Date.parse(value) rescue value if value.is_a?(String) && value.length <= 10 # rubocop:disable Style/RescueModifier
    value = Time.zone.parse(value) if value.is_a?(String)
    value = value.beginning_of_day if value.is_a?(Date)
    super
  end

  def period_to=(value)
    value = value.presence
    value = Date.parse(value) rescue value if value.is_a?(String) && value.length <= 10 # rubocop:disable Style/RescueModifier
    value = Time.zone.parse(value) if value.is_a?(String)
    value = value.end_of_day if value.is_a?(Date)
    super
  end

  def organisation
    super || self.organisation = data_digest_template&.organisation
  end

  def records
    data_digest_template.records(period_from..period_to)
  end

  def crunch
    self.data = data_digest_template.crunch(records)
  end

  def crunch!
    update(crunching_started_at: Time.zone.now) &&
      crunch &&
      update(crunching_finished_at: Time.zone.now)
  end

  def crunching_finished?
    crunching_finished_at.present?
  end

  def format(format, **options)
    data || crunch
    formatter = formatters[format&.to_sym]
    block = formatter&.block
    instance_exec(options, &block) if block.present?
  end

  def formatters
    data_digest_template.class.formatters
  end

  def localized_period
    I18n.t('data_digests.period_short',
           period_from: (period_from && I18n.l(period_from)) || '',
           period_to: (period_to && I18n.l(period_to)) || '')
  end
end
