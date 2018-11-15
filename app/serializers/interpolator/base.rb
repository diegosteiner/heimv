class Interpolator
  class Base
    include Rails.application.routes.url_helpers

    def initialize(subject)
      @subject = subject
    end

    def self.flatten_hash(hash, prepend_keys = [], joint = '_')
      return { prepend_keys => hash } unless hash.is_a?(Hash)

      hash.inject({}) do |memo, pair|
        memo.merge!(flatten_hash(pair.last, (Array.wrap(prepend_keys) + [pair.first]).join(joint), joint))
      end
    end

    def serializable_hash
      self.class.flatten_hash(unflattened_serializable_hash)
    end
  end
end
