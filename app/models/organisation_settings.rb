# frozen_string_literal: true

class OrganisationSettings
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :require_tenant_birthdate, :boolean, default: true
  attribute :feature_new_bookings, :boolean, default: false

  def to_h
    attributes
  end
end
