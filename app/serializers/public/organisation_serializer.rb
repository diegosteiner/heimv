# frozen_string_literal: true

module Public
  class OrganisationSerializer < ApplicationSerializer
    identifier :slug

    association :booking_categories, blueprint: Public::BookingCategorySerializer
    association :homes, blueprint: Public::HomeSerializer do |organisation|
      organisation.homes.kept
    end

    fields :name, :address, :email, :currency, :country_code

    field :booking_agents do |organisation|
      organisation.booking_agents.any?
    end

    field :logo_url do |organisation|
      organisation.logo.present? && url_for(organisation.logo)
    end
  end
end
