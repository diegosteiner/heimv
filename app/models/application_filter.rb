
class ApplicationFilter
  include ActiveModel::Model
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Attributes

  class << self
    attr_reader :reducers

    def filter(*params, &block)
      @reducers ||= {}
      @reducers[params] = block
    end
  end

  def reduce(relation)
    self.class.reducers.reduce(relation) do |rel, (params, block)|
      params = attributes.with_indifferent_access.slice(*params)
      next rel unless block.respond_to?(:call) && params.values.any?(&:present?)
      block.call(params, rel)
    end
  end

  def cached(relation)
    Rails.cache.fetch(cache_key(relation), expires_in: 15.minutes) do
      reduce(relation)
    end
  end

  def cache_key(relation)
    ([self.class] + relation.pluck(:id) + attributes.values).join('-')
  end

end
