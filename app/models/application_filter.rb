class ApplicationFilter
  include ActiveModel::Model
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Attributes
  # include ActiveModel::AttributeAssignment

  class << self
    attr_reader :reducers

    def filter(&block)
      @reducers ||= []
      @reducers << block
    end
  end

  def active?
    attributes.values.any?(&:present?)
  end

  def reduce(base_relation)
    self.class.reducers.reduce(base_relation) do |relation, block|
      next relation unless block.respond_to?(:call)

      instance_exec(relation, &block)
    end
  end

  def cached(base_relation)
    ids = Rails.cache.fetch(cache_key(base_relation), expires_in: 15.minutes) do
      reduce(base_relation).map(&:id)
    end
    base_relation.model.find(ids)
  end

  def cache_key(relation)
    ([self.class] + relation.pluck(:id) + attributes.values).join('-')
  end
end
