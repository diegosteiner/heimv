# frozen_string_literal: true

class RefBuilder
  DEFAULT_TEMPLATE = nil

  def initialize(organisation)
    @organisation = organisation
  end

  def self.ref_parts
    @ref_parts ||= {}
  end

  def self.ref_part(hash)
    ref_parts.merge!(hash)
  end

  def generate_lazy(template_string, **override)
    return if template_string.nil?

    ref_parts = self.class.ref_parts.select { |key| template_string.include?(key.to_s) }
                    .transform_values { |callable| instance_eval(&callable) }
                    .merge(**override)
    format(template_string, ref_parts)
  end
end
