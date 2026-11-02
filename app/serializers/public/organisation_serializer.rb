# frozen_string_literal: true

module Public
  class OrganisationSerializer < ApplicationSerializer
    identifier :slug

    association :booking_categories, blueprint: Public::BookingCategorySerializer do |organisation|
      organisation.booking_categories.kept.ordered
    end

    association :calendar_labels, blueprint: Public::CalendarLabelSerializer do |organisation|
      organisation.calendar_labels.kept.ordered
    end
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

    view :bookable do
      association :homes, blueprint: Public::HomeSerializer, view: :bookable do |organisation|
        organisation.homes.bookable.kept
      end
    end
  end
end
