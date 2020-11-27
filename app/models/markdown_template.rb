# frozen_string_literal: true

# == Schema Information
#
# Table name: markdown_templates
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
#  index_markdown_templates_on_home_id                              (home_id)
#  index_markdown_templates_on_key_and_home_id_and_organisation_id  (key,home_id,organisation_id) UNIQUE
#  index_markdown_templates_on_organisation_id                      (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

class MarkdownTemplate < ApplicationRecord
  Requirement = Struct.new(:key, :context)
  extend Mobility
  translates :title, :body, column_suffix: '_i18n', locale_accessors: true

  belongs_to :organisation
  belongs_to :home, optional: true
  has_many :notifications, inverse_of: :markdown_template, dependent: :nullify

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

  def self.by_key!(key, home_id: nil)
    where(key: key, home_id: [home_id, nil]).order(home_id: :DESC).take!
  end

  def self.by_key(key, home_id: nil)
    by_key!(key, home_id: home_id)
  rescue ActiveRecord::RecordNotFound => e
    defined?(Raven) && Raven.capture_exception(e) || Rails.logger.warn(e.message)
    nil
  end
end
