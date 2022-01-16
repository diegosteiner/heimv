# frozen_string_literal: true

module Public
  class OrganisationSerializer < ApplicationSerializer
    association :booking_purposes, blueprint: Public::BookingPurposeSerializer
    association :homes, blueprint: Public::HomeSerializer

    fields :name, :address, :booking_flow_type, :invoice_ref_strategy_type, :location, :slug,
           :esr_beneficiary_account, :email, :payment_deadline, :notifications_enabled

    field :documents do |organisation|
      DesignatedDocument.designations.filter_map do |designation|
        next unless organisation.designated_documents.exists?(designation: designation)

        [designation, url.public_designated_document_url(org: organisation.slug, designation: designation)]
      end.to_h
    end

    field :logo do |organisation|
      organisation.logo.present? && url.url_for(organisation.logo)
    end

    field :links do |organisation|
      {
        post_bookings: url.public_bookings_url(org: organisation.slug, format: :json)
      }
    end
  end
end
