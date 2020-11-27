# frozen_string_literal: true

# == Schema Information
#
# Table name: markdown_templates
#
#  id              :bigint           not null, primary key
#  body_i18n       :jsonb
#  key             :string
#  namespace       :string
#  title_i18n      :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  home_id         :bigint
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_markdown_templates_on_home_id          (home_id)
#  index_markdown_templates_on_namespace        (namespace)
#  index_markdown_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

class MarkdownTemplate < ApplicationRecord
  extend Mobility
  translates :title, :body, column_suffix: '_i18n', locale_accessors: true

  belongs_to :organisation
  belongs_to :home, optional: true
  has_many :notifications, inverse_of: :markdown_template, dependent: :nullify

  enum namespace: { notification: Notification.to_s, contract: Contract.to_s, invoice: Invoice.to_s }

  validates :key, uniqueness: { scope: %i[organisation_id home_id namespace] }

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

  def self.by_key!(key, namespace: nil, home_id: nil)
    where(namespace: namespace, key: key, home_id: [home_id, nil]).order(home_id: :DESC).take!
  end

  def self.by_key(key, namespace: nil, home_id: nil)
    by_key!(key, namespace: namespace, home_id: home_id)
  rescue ActiveRecord::RecordNotFound => e
    defined?(Raven) && Raven.capture_exception(e) || Rails.logger.warn(e.message)
    nil
  end
end
