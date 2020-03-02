module MultiparameterAttributes
  extend ActiveSupport::Concern

  class_methods do
    def multi_param_attributes
      @multi_param_attributes ||= {}
    end

    def multi_param_attribute(multi_param_attributes)
      @multi_param_attributes = multi_param_attributes.merge(multi_param_attributes).stringify_keys
    end
  end

  def preprocess_multi_param_attributes(attributes)
    self.class.multi_param_attributes.each do |key, attribute_klass|
      preprocess_multi_param_attribute(attributes, key, attribute_klass)
    end
  end

  def preprocess_multi_param_attribute(attributes, multi_param_key, attribute_klass)
    return if attributes.blank? || attributes.include?(multi_param_key)

    matching_keys = find_matching_keys(attributes, multi_param_key)
    multi_param_values = matching_keys.sort.map { |key| attributes.delete(key)&.to_i }
    attributes[multi_param_key] = attribute_klass.new(*multi_param_values.compact) if multi_param_values.any?
  rescue ArgumentError
    attributes[multi_param_key] = nil
  end

  def find_matching_keys(attributes, multi_param_key)
    attributes.keys.select { |key| key.to_s.start_with?(multi_param_key.to_s) }
  end

  def assign_attributes(attributes)
    preprocess_multi_param_attributes(attributes)
    super
  end
end
