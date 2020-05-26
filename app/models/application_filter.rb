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

  def cached(base_relation)
    ids = Rails.cache.fetch(cache_key(base_relation), expires_in: 15.minutes) do
      apply(base_relation).map(&:id)
    end
    base_relation.model.find(ids)
  end

  def cache_key(relation)
    ([self.class] + relation.pluck(:id) + attributes.values).join('-')
  end
end
