# frozen_string_literal: true

# == Schema Information
#
# Table name: markdown_templates
#
#  id              :bigint           not null, primary key
#  body            :text
#  key             :string
#  locale          :string
#  namespace       :string
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  home_id         :bigint
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_markdown_templates_on_home_id          (home_id)
#  index_markdown_templates_on_key_composition  (key,locale,organisation_id,home_id,namespace) UNIQUE
#  index_markdown_templates_on_namespace        (namespace)
#  index_markdown_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

class MarkdownTemplate < ApplicationRecord
  class TemplateMissingError < StandardError; end

  belongs_to :organisation
  belongs_to :home, optional: true
  has_many :notifications, inverse_of: :markdown_template, dependent: :nullify

  enum namespace: { notification: Notification.to_s, contract: Contract.to_s, invoice: Invoice.to_s }

  validates :key, :locale, presence: true
  validates :key, uniqueness: { scope: %i[locale organisation_id home_id namespace] }

  def to_markdown
    Markdown.new(body)
  end

  def interpolate(context)
    liquid_template = Liquid::Template.parse(body)
    Markdown.new(liquid_template.render!(context.to_liquid))
  end

  def interpolate_title(context)
    liquid_template = Liquid::Template.parse(title)
    liquid_template.render!(context.to_liquid)
  end

  alias % interpolate

  def self.by_key!(key, locale: I18n.locale, **other)
    find_by({ key: key, locale: locale }.merge(other)) ||
      find_by({ key: key, locale: locale }) ||
      find_by({ key: key }) ||
      raise(TemplateMissingError, "MarkdownTemplate #{key} with locale #{locale} was not found")
  end

  def self.by_key(key, locale: I18n.locale, **other)
    by_key!(key, locale: locale, **other)
  rescue TemplateMissingError => e
    defined?(Raven) && Raven.capture_exception(e) || Rails.logger.warn(e.message)
    nil
  end

  def self.create_missing(organisation, locale: (I18n.available_locales - [:en]))
    missing(organisation, locale: locale).each(&:save)
  end

  def self.missing(organisation, locale: (I18n.available_locales - [:en]))
    Array.wrap(locale).map do |locale_to_check|
      set_keys = where(locale: locale_to_check, organisation: organisation).pluck(:key).map(&:to_sym)
      missing_keys = organisation.booking_strategy.markdown_template_keys - set_keys
      missing_keys.map { |missing_key| new(key: missing_key, organisation: organisation, locale: locale_to_check) }
    end.flatten
  end
end
