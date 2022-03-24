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
  translates :title, :body, column_suffix: '_i18n', locale_accessors: true

  belongs_to :organisation, inverse_of: :rich_text_templates
  belongs_to :home, optional: true, inverse_of: :rich_text_templates
  has_many :notifications, inverse_of: :rich_text_template, dependent: :nullify

  scope :ordered, -> { order(key: :ASC, home_id: :ASC) }
  scope :enabled, -> { where(enabled: true) }

  validates :key, uniqueness: { scope: %i[key organisation_id home_id] }
  validate do
    required_templates = self.class.required_templates
    errors.add(:key, :invalid) if key && required_templates.any? && !required_templates.key?(key.to_sym)
  end
  validate do
    body_i18n.each do |locale, body|
      Liquid::Template.parse(body, error_mode: :strict)
    rescue Liquid::SyntaxError
      errors.add("body_#{locale}", :invalid)
    end
  end
  validate do
    title_i18n.each do |_locale, title|
      Liquid::Template.parse(title, error_mode: :strict)
    rescue Liquid::SyntaxError
      errors.add("body_#{title}", :invalid)
    end
  end

  def interpolate(context)
    context = context&.stringify_keys || {}
    parts = [title, body].map do |part|
      liquid_template = Liquid::Template.parse(part)
      self.class.sanitize_html(liquid_template.render!(context.to_liquid))
    end
    InterpolationResult.new(*parts)
  end

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

    def replace_in_template!(search, replace)
      find_each do |rich_text_template|
        rich_text_template.body_i18n.transform_values! { _1.gsub(search, replace) }
        rich_text_template.title_i18n.transform_values! { _1.gsub(search, replace) }
        rich_text_template.save
      end
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

    def sanitize_html(html)
      sanitizer = Rails::Html::SafeListSanitizer.new
      sanitizer.sanitize(html,
                         tags: Rails::Html::SafeListSanitizer.allowed_tags + %w[table tr td th thead tbody],
                         attributes: Rails::Html::SafeListSanitizer.allowed_attributes)
    end
  end
end
