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
# Indexes
#
#  index_rich_text_templates_on_key_and_organisation_id  (key,organisation_id) UNIQUE
#  index_rich_text_templates_on_organisation_id          (organisation_id)
#  index_rich_text_templates_on_type                     (type)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class RichTextTemplate < ApplicationRecord
  InterpolationResult = Struct.new(:title, :body)
  InvalidDefinition = Class.new(StandardError)
  InvalidContext = Class.new(StandardError)
  NoTemplate = Class.new(StandardError)

  extend Mobility
  extend Translatable

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
      key && definitions.keys.include?(key.to_sym)
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
  has_many :notifications, inverse_of: :rich_text_template, dependent: :nullify

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

  def interpolate(context)
    context = TemplateContext.new(context) unless context.is_a?(TemplateContext)
    parts = [title, body].map do |part|
      template = Liquid::Template.parse(part)
      RichTextSanitizer.sanitize(template.render!(context.to_h))
    end
    InterpolationResult.new(*parts)
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
end
