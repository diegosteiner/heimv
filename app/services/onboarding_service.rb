# frozen_string_literal: true

class OnboardingService
  attr_reader :organisation

  def self.create(**attributes)
    defaults = {
      booking_flow_type: BookingFlows::Default
    }
    organisation = Organisation.create!(defaults.merge(attributes))
    new(organisation)
  end

  def self.clone_organisation(origin)
    new(origin.dup)
  end

  def add_or_invite_user!(...)
    add_or_invite_user(...).save!
  end

  def add_or_invite_user(email: organisation.email, role: :manager, invited_by: nil, password: nil)
    user = User.find_or_initialize_by(email:)

    if user.new_record?
      user.update!(password: password || SecureRandom.base64(32))
      user.invite!(invited_by) if password.blank?
    end

    user.organisation_users.create(organisation:, role:).tap do
      user.update(default_organisation: organisation) if user.default_organisation.blank?
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
