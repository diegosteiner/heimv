# frozen_string_literal: true

class ApplicationFilter
  include ActiveModel::Model
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Attributes

  def apply(base_relation)
    self.class.filters.values.inject(base_relation) do |relation, filter_block|
      instance_exec(relation, &filter_block) || relation
    end
  end

  def self.filter(name, &block)
    filters[name] = block
  end

  def self.filters
    @filters ||= {}
  end

  def active?
    attributes.values.any?(&:present?)
  end

  def cached_ids(base_relation)
    Rails.cache.fetch(cache_key(base_relation), expires_in: 15.minutes) do
      apply(base_relation).map(&:id)
    end
  end

  def apply_cached(base_relation)
    base_relation.where(id: cached_ids(base_relation))
  end

  def cache_key(relation)
    digest = Digest::SHA1
    [self.class, digest.hexdigest(relation.pluck(:id).to_s), digest.hexdigest(attributes.values.to_s)].join('-')
  end
end
