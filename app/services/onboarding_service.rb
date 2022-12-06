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

  def add_or_invite_user!(email: organisation.email, role: :manager, invited_by: nil, password: nil)
    User.find_or_initialize_by(email: email).tap do |user|
      user.invite(invited_by) unless user.new_record? || password.present?
      user.password = password if password.present?
      user.save!
      user.organisation_users.create(organisation: organisation, role: role)
      user.default_organisation ||= organisation
      user.save!
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
