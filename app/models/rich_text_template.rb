# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id                 :bigint           not null, primary key
#  body_i18n          :jsonb
#  body_i18n_markdown :jsonb
#  enabled            :boolean          default(TRUE)
#  key                :string
#  title_i18n         :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  home_id            :bigint
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_rich_text_templates_on_home_id                        (home_id)
#  index_rich_text_templates_on_key_and_home_and_organisation  (key,home_id,organisation_id) UNIQUE
#  index_rich_text_templates_on_organisation_id                (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

class RichTextTemplate < ApplicationRecord
  Requirement = Struct.new(:key, :context, :required_by, :optional)
  InterpolationResult = Struct.new(:title, :body)

  extend Mobility
  extend Translatable

  class << self
    def by_key!(key, home_id: nil)
      where(key: key, home_id: [home_id, nil]).order(home_id: :ASC).take!
    end

    def by_key(key, home_id: nil)
      by_key!(key, home_id: home_id)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.warn(e.message)
      nil
    end

    def template_key_valid?(key)
      key && required_templates.keys.include?(key.to_sym)
    end

    def required_templates
      @required_templates ||= {}
    end

    def require_template(key, context: [], required_by: nil, optional: false)
      key = key.to_sym
      requirement = self::Requirement.new(key, context, required_by, optional)
      required_templates[key] ||= []
      required_templates[key] << requirement
    end
  end

  translates :title, :body, column_suffix: '_i18n', locale_accessors: true

  belongs_to :organisation, inverse_of: :rich_text_templates
  belongs_to :home, optional: true, inverse_of: :rich_text_templates
  has_many :notifications, inverse_of: :rich_text_template, dependent: :nullify

  scope :ordered, -> { order(key: :ASC, home_id: :ASC) }
  scope :enabled, -> { where(enabled: true) }

  validates :key, uniqueness: { scope: %i[key organisation_id home_id] }
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
    context = context&.stringify_keys || {}
    parts = [title, body].map do |part|
      liquid_template = Liquid::Template.parse(part)
      RichTextSanitizer.sanitize(liquid_template.render!(context.to_liquid))
    end
    InterpolationResult.new(*parts)
  end
end
