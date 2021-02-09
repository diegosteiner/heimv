# frozen_string_literal: true

module Public
  class OrganisationSerializer < ApplicationSerializer
    association :booking_purposes, blueprint: Public::BookingPurposeSerializer
    fields :name, :address, :booking_strategy_type, :invoice_ref_strategy_type, :location, :slug,
           :esr_beneficiary_account, :notification_footer, :email, :payment_deadline, :notifications_enabled

    field :links do |organisation|
      org = organisation.slug
      {
        privacy_statement_pdf: url.download_url(slug: I18n.t(:privacy_statement_pdf, scope: %i[downloads slug]),
                                                org: org),
        terms_pdf: url.download_url(slug: I18n.t(:terms_pdf, scope: %i[downloads slug]),
                                    org: org)
      }
    end
  end
end
