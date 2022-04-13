# frozen_string_literal: true

class OrganisationSettings
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :tenant_birth_date_required, :boolean, default: true
  attribute :feature_new_bookings, :boolean, default: false

  def to_h
    attributes
  end
end
