# frozen_string_literal: true

class OnboardingService
  attr_reader :organisation

  def self.create(**attributes)
    defaults = {
      booking_flow_type: BookingFlows::Default,
      invoice_ref_strategy_type: RefStrategies::ESR
    }
    organisation = Organisation.create!(defaults.merge(attributes))
    new(organisation)
  end

  def self.clone_organisation(origin)
    new(origin.dup)
  end

  def add_or_invite_user!(email: organisation.email, role: :manager, invited_by: nil, password: nil)
    user = User.find_or_initialize_by(email: email)
    user.update!(password: password || SecureRandom.base64(32)) if user.new_record?
    user.invite!(invited_by) if password.blank? && user.new_record?
    user.organisation_users.create!(organisation: organisation, role: role).tap do
      user.update!(default_organisation: organisation) if user.default_organisation.blank?
    end
  end

  def initialize(organisation)
    @organisation = organisation
  end

  def create_home!(**attributes)
    organisation.homes.create!(attributes)
  end

  def create_missing_rich_text_templates!
    RichTextTemplateService.new(organisation).create_missing!
  end
end
