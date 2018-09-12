class HashFlattener
  def call(hash, prepend_keys = [])
    return { prepend_keys => hash } unless hash.is_a?(Hash)

    hash.inject({}) { |h, v| h.merge! call(v.last, (Array.wrap(prepend_keys) + [v.first]).join('_')) }
  end

  def self.call(*args)
    new.call(*args)
  end
end
