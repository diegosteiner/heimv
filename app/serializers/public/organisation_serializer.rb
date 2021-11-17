# frozen_string_literal: true

module Public
  class OrganisationSerializer < ApplicationSerializer
    association :booking_purposes, blueprint: Public::BookingPurposeSerializer
    association :homes, blueprint: Public::HomeSerializer

    fields :name, :address, :booking_flow_type, :invoice_ref_strategy_type, :location, :slug,
           :esr_beneficiary_account, :email, :payment_deadline, :notifications_enabled

    field :links do |organisation|
      {
        logo: (organisation.logo.present? && url.url_for(organisation.logo)),
        post_bookings: url.public_bookings_url(org: organisation.slug, format: :json),
        terms_pdf: url.download_url(slug: I18n.t(:terms_pdf, scope: %i[downloads slug]), org: organisation.slug),
        privacy_statement_pdf: url.privacy_url(org: organisation.slug)
      }
    end
  end
end
