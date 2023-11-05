# frozen_string_literal: true

module Public
  class OrganisationSerializer < ApplicationSerializer
    association :booking_categories, blueprint: Public::BookingCategorySerializer
    association :homes, blueprint: Public::HomeSerializer

    fields :name, :address, :booking_flow_type, :invoice_ref_strategy_type, :location, :slug,
           :esr_beneficiary_account, :email, :notifications_enabled, :currency

    field :designated_documents do |organisation|
      organisation.designated_documents.pluck(:designation).map do |designation|
        next if designation.blank?

        [designation,
         url.public_designated_document_url(org: organisation, designation:, locale: I18n.locale)]
      end.compact_blank.to_h
    end

    field :logo do |organisation|
      organisation.logo.present? && url.url_for(organisation.logo)
    end

    field :booking_agents do |organisation|
      organisation.booking_agents.any?
    end

    field :links do |organisation|
      {
        post_bookings: url.public_bookings_url(org: organisation, locale: I18n.locale, format: :json)
      }
    end
  end
end
