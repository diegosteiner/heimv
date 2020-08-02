# frozen_string_literal: true

module Import
  class Base
    attr_reader :options, :organisation

    def initialize(organisation, options = { replace: false })
      @organisation = organisation
      @options = options
    end

    def export
      _export
    end

    def import(serialized)
      Rails.logger.info "Importing #{serialized} with #{self.class.name}"
      return false unless serialized.is_a?(Hash)

      ActiveRecord::Base.transaction do
        _import(serialized)
      end
    end

    def relevant_attributes
      []
    end
  end
end
