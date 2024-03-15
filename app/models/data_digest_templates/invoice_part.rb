# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digest_templates
#
#  id               :bigint           not null, primary key
#  columns_config   :jsonb
#  group            :string
#  label            :string
#  prefilter_params :jsonb
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_data_digest_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module DataDigestTemplates
  class InvoicePart < DataDigestTemplate
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Invoice.human_attribute_name(:ref),
        body: '{{ invoice.ref }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      },
      {
        header: ::Booking.human_attribute_name(:home_id),
        body: '{{ booking.home_id }}'
      },
      {
        header: ::Home.model_name.human,
        body: '{{ booking.home.name }}'
      },
      {
        header: ::Invoice.human_attribute_name(:amount_paid),
        body: '{{ invoice.percentage_paid }}'
      },
      {
        header: ::Invoice.human_attribute_name(:issued_at),
        body: '{{ invoice.issued_at }}'
      },
      {
        header: ::Tarif.model_name.human,
        body: '{{ invoice_part.tarif_id }}'
      },
      {
        header: ::Tarif.human_attribute_name(:label),
        body: '{{ invoice_part.tarif.label }}'
      },
      {
        header: ::InvoicePart.human_attribute_name(:label),
        body: '{{ invoice_part.label }}'
      },
      {
        header: ::InvoicePart.human_attribute_name(:breakdown),
        body: '{{ invoice_part.breakdown }}'
      },
      {
        header: ::InvoicePart.human_attribute_name(:amount),
        body: '{{ invoice_part.amount | round: 2 }}'
      },
      {
        header: ::Usage.human_attribute_name(:remarks),
        body: '{{ invoice_part.usage.remarks }}'
      }
    ].freeze

    column_type :default do
      body do |invoice_part, template_context_cache|
        booking = invoice_part.booking
        context = template_context_cache[cache_key(invoice_part)] ||=
          TemplateContext.new(booking:, invoice: invoice_part.invoice,
                              invoice_part:, organisation: booking.organisation).to_h
        @templates[:body]&.render!(context)
      end
    end

    def periodfilter(period = nil)
      filter_class.new(issued_at_after: period&.begin, issued_at_before: period&.end)
      # rescue StandardError
    end

    def filter_class
      ::InvoicePart::Filter
    end

    def base_scope
      @base_scope ||= ::InvoicePart.joins(usage: :tarif, invoice: :booking)
                                   .where(invoices: { bookings: { organisation_id: organisation } })
    end
  end
end
