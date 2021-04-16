# frozen_string_literal: true

# == Schema Information
#
# Table name: rich_text_templates
#
#  id              :bigint           not null, primary key
#  body_i18n       :jsonb
#  key             :string
#  title_i18n      :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  home_id         :bigint
#  organisation_id :bigint           not null
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
  Requirement = Struct.new(:key, :context, :required_by)
  extend Mobility
  include Translatable
  translates :title, :body, column_suffix: '_i18n', locale_accessors: true

  belongs_to :organisation
  belongs_to :home, optional: true
  has_many :notifications, inverse_of: :rich_text_template, dependent: :nullify

  validates :key, uniqueness: { scope: %i[key organisation_id home_id] }

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

  class << self
    def by_key!(key, home_id: nil)
      where(key: key, home_id: [home_id, nil]).order(home_id: :DESC).take!
    end

    def by_key(key, home_id: nil)
      by_key!(key, home_id: home_id)
    rescue ActiveRecord::RecordNotFound => e
      defined?(Sentry) && Sentry.capture_exception(e) || Rails.logger.warn(e.message)
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

    def require_template(key, context = [], required_by = nil)
      required_templates[key.to_sym] ||= []
      required_templates[key.to_sym] << RichTextTemplate::Requirement.new(key, context, required_by)
    end

    def missing_templates(organisation)
      required_templates.keys.map(&:to_s) - organisation.rich_text_templates.where(home_id: nil).pluck(:key)
    end
  end
end
