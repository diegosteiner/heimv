# frozen_string_literal: true

class ApplicationParams
  class << self
    def permit(params)
      preprocess_multi_params(params)
      permit_nested(params)
      params&.permit(self.permitted_keys + self.permitted_nested_keys) || default
    end

    def multi_param_classes
      @multi_param_classes ||= {}
    end

    def multi_param(multi_param_classes)
      @multi_param_classes = multi_param_classes.merge(multi_param_classes).stringify_keys
    end

    def preprocess_multi_params(params)
      multi_param_classes.each { |key, params_klass| preprocess_multi_param(params, key, params_klass) }
    end

    def preprocess_multi_param(params, multi_param_key, multi_param_class)
      return if params.blank?

      multi_param_keys = params.keys.select { |key| key.to_s.start_with?(multi_param_key.to_s) }
      multi_param_values = multi_param_keys.sort.map { |key| params.delete(key)&.to_i }
      params[multi_param_key] = multi_param_class.new(*multi_param_values.compact)
    rescue ArgumentError
      params[multi_param_key] = nil
    end

    def nested_param_classes
      @nested_param_classes ||= {}
    end

    def nested(nested_param_classes)
      @nested_param_classes = nested_param_classes.merge(nested_param_classes)
    end

    def permitted_nested_keys
      [Hash[nested_param_classes.keys.map { |nested_param_key| [nested_param_key, {}] }]]
    end

    def permit_nested(params)
      return if params.blank?

      nested_param_classes.each do |key, params_klass|
        nested_params = params.delete(key)
        next unless nested_params && params_klass.respond_to?(:permit)

        params[key] = params_klass.permit(nested_params)
        params.permit(key => {})
      end
    end


    def default
      ActionController::Parameters.new
    end

    def permitted_keys
      []
    end
  end
end
