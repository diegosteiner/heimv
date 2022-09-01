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

  def add_or_invite_user!(email: organisation.email, password: SecureRandom.base64(32), role: :manager)
    User.find_or_initialize_by(email: email).tap do |user|
      if user.new_record?
        user.update!(password: password, default_organisation_id: nil) &&
          user.send_reset_password_instructions
      end
      user.organisation_users.create(organisation: organisation, role: role)
      user.default_organisation ||= organisation
      user.save
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
