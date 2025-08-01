# frozen_string_literal: true

class ApplicationFilter
  include ActiveModel::Model
  extend TemplateRenderable
  include TemplateRenderable
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Attributes

  def initialize(attributes = {})
    super(attributes.symbolize_keys.slice(*self.class.attribute_names.map(&:to_sym)))
  end

  def apply(base_relation, cached: false)
    return base_relation.none unless valid?
    return base_relation.where(id: cached_ids(base_relation, cached_for: cached)) if cached

    self.class.filters.values.reduce(base_relation) do |relation, filter_block|
      instance_exec(relation, &filter_block) || relation
    end
  end

  def self.filter(name, &block)
    filters[name] = block
  end

  def self.filters
    @filters ||= {}
  end

  def any?
    !attributes.values.all?(&:nil?)
  end

  def cached_ids(base_relation, cached_for: nil)
    Rails.cache.fetch(cache_key(base_relation), expires_in: cached_for || 5.minutes) do
      apply(base_relation, cached: false).map(&:id)
    end
  end

  def cache_key(base_relation)
    [self.class, Digest::SHA1.hexdigest(attributes.values.to_s), base_relation.maximum(:updated_at)].join('-')
  end

  def reflections
    {}
  end
end
