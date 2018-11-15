class MarkdownTemplate < ApplicationRecord
  validates :key, :locale, presence: true
  validates :key, uniqueness: true

  def interpolatable_type
    super&.constantize
  end

  def to_markdown
    Markdown.new(body)
  end

  def self.key(*partial_keys)
    partial_keys.join('/')
  end

  def self.find_by_key(*partial_keys)
    conditions = partial_keys.last.is_a?(Hash) ? partial_keys.pop : { locale: I18n.locale }
    find_by(conditions.merge(key: key(*partial_keys)))
  end
end
