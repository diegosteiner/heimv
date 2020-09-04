# frozen_string_literal: true

# == Schema Information
#
# Table name: markdown_templates
#
#  id              :bigint           not null, primary key
#  body            :text
#  key             :string
#  locale          :string
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_markdown_templates_on_key_and_locale_and_organisation_id  (key,locale,organisation_id) UNIQUE
#  index_markdown_templates_on_organisation_id                     (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class MarkdownTemplate < ApplicationRecord
  belongs_to :organisation
  has_many :notifications, inverse_of: :markdown_template, dependent: :nullify

  validates :key, :locale, presence: true
  validates :key, uniqueness: { scope: %i[locale organisation_id] }

  def to_markdown
    Markdown.new(body)
  end

  def interpolate(context)
    liquid_template = Liquid::Template.parse(body)
    Markdown.new(liquid_template.render!(context.to_liquid, [Filters]))
  end

  alias % interpolate

  def self.by_key(key, locale: I18n.locale)
    by_key!(key, locale: locale)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("MarkdownTemplate #{key} with locale #{locale} was not found")
    nil
  end

  def self.by_key!(key, locale: I18n.locale)
    find_by!(key: key, locale: locale)
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
