# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id              :bigint           not null, primary key
#  autodeliver     :boolean          default(TRUE)
#  body_i18n       :jsonb
#  enabled         :boolean          default(TRUE)
#  key             :string
#  title_i18n      :jsonb
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#

class RichTextTemplate < ApplicationRecord
  InterpolationResult = Struct.new(:title, :body, :locale)
  InvalidDefinition = Class.new(StandardError)
  InvalidContext = Class.new(StandardError)
  NoTemplate = Class.new(StandardError)

  extend Mobility
  extend Translatable

  module Definition
    def rich_text_templates
      @rich_text_templates ||= {}
    end

    def use_template(key, *, **)
      rich_text_templates[key] = RichTextTemplate.define(key, *, **)
    end

    def use_mail_template(key, *, **)
      rich_text_templates[key] = MailTemplate.define(key, *, **)
    end
  end

  class << self
    def by_key!(key)
      where(key:).take!
    rescue ActiveRecord::RecordNotFound
      raise NoTemplate, "No template found for key '#{key}'"
    end

    def by_key(key)
      by_key!(key)
      # rescue ActiveRecord::RecordNotFound => e
      #   Rails.logger.warn(e.message)
    rescue NoTemplate
      nil
    end

    def template_key_valid?(key)
      key && definitions.key?(key.to_sym)
    end

    def definitions
      return @definitions ||= {} if self == RichTextTemplate

      RichTextTemplate.definitions.filter { _2[:type] == self }
    end

    def undefine(key)
      RichTextTemplate.definitions.delete(key)
    end

    def define(key, **definition)
      key = key&.to_sym
      raise InvalidDefinition if key.blank? || RichTextTemplate.definitions.key?(key)

      RichTextTemplate.definitions[key] = definition.merge(type: self, key:)
    end
  end

  translates :title, :body, column_suffix: '_i18n', locale_accessors: true

  belongs_to :organisation, inverse_of: :rich_text_templates

  scope :ordered, -> { order(key: :ASC) }
  scope :enabled, -> { where(enabled: true) }

  validates :key, uniqueness: { scope: %i[key organisation_id] }
  validate { errors.add(:key, :invalid) if key && !self.class.template_key_valid?(key.to_sym) }
  validate do
    body_i18n.each do |locale, body|
      Liquid::Template.parse(body, error_mode: :strict)
    rescue Liquid::SyntaxError
      errors.add("body_#{locale}", :invalid)
    end
  end
  validate do
    title_i18n.each do |locale, title|
      Liquid::Template.parse(title, error_mode: :strict)
    rescue Liquid::SyntaxError
      errors.add("body_#{locale}", :invalid)
    end
  end

  def interpolate(context, locale: I18n.locale)
    I18n.with_locale(locale) do
      context = TemplateContext.new(context) unless context.is_a?(TemplateContext)
      parts = [title, body].map do |part|
        template = Liquid::Template.parse(part, environment: self.class.template_environment)
        RichTextSanitizer.sanitize(template.render!(context.to_h))
      end
      InterpolationResult.new(*parts)
    end
  end

  def definition
    RichTextTemplate.definitions[key&.to_sym]
  end

  def use(**context)
    raise InvalidDefinition, "No definition found for key '#{key}'" unless definition

    missing_context = definition.fetch(:context, []) - context.keys
    raise InvalidContext, "Missing keys were: #{missing_context.join(', ')}" if missing_context.any?

    interpolate(context)
  end

  def gsub!(search, replace = '', within_title: true, within_body: true)
    self.title_i18n = title_i18n.transform_values { it&.gsub(search, replace) } if within_title
    self.body_i18n = body_i18n.transform_values { it&.gsub(search, replace) } if within_body
  end

  def include?(search, within_title: true, within_body: true) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    return true if within_title && title_i18n.values.any? { it&.include?(search) }
    return true if within_body && body_i18n.values.any? { it&.include?(search) }

    false
  end

  def load_locale_defaults(key: self.key, locales: I18n.available_locales)
    locales = Array.wrap(locales).map(&:to_sym)
    defaults = self.class.defaults_for_key(key:, locales:)
    title_i18n.merge!(defaults[:title_i18n].slice(*locales).stringify_keys)
    body_i18n.merge!(defaults[:body_i18n].slice(*locales).stringify_keys)
  end

  def self.defaults_for_key(key:, locales: I18n.available_locales)
    { title_i18n: {}, body_i18n: {} }.tap do |defaults|
      locales.map do |locale|
        key_in_locale = I18n.t(key, scope: [:rich_text_templates], locale:, default: nil)
        defaults[:title_i18n][locale] = key_in_locale&.fetch(:default_title, nil)
        defaults[:body_i18n][locale] = key_in_locale&.fetch(:default_body, nil)
      end
    end
  end

  def self.template_environment
    @template_environment ||= Liquid::Environment.build do |environment|
      environment.error_mode = :strict unless Rails.env.production?
      environment.register_filter(TemplateEnvironment::Default)
    end
  end
end
