# frozen_string_literal: true

class OrganisationSettings < Settings
  attribute :tenant_birth_date_required, :boolean, default: true
  attribute :feature_new_bookings, :boolean, default: false
end
