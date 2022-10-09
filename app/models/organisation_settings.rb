# frozen_string_literal: true

class OrganisationSettings < Settings
  attribute :tenant_birth_date_required, :boolean, default: true
end
