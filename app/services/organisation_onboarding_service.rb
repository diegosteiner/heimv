# frozen_string_literal: true

class OrganisationOnboardingService
  attr_reader :organisation

  def initialize(organisation)
    @organisation = organisation
  end

  def create_missing_markdown_templates!
    missing_markdown_templates.each { |key| organisation.markdown_templates.create(key: key) }
  end 

  def missing_markdown_templates
    required_markdown_templates = organisation.booking_strategy.markdown_templates.keys.map(&:to_s)
    required_markdown_templates - organisation.markdown_templates.where(home_id: nil).pluck(:key)
  end
end
