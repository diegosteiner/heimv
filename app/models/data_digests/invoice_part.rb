# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
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
#  index_data_digests_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module DataDigests
  class InvoicePart < DataDigest
    ::DataDigest.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Invoice.human_attribute_name(:ref),
        body: '{{ invoice_part.invoice.ref }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      },
      {
        header: ::Invoice.human_attribute_name(:paid_at),
        body: '{{ invoice_part.invoice.paid_at }}'
      },
      {
        header: ::Invoice.human_attribute_name(:issued_at),
        body: '{{ invoice_part.invoice.issued_at }}'
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
        header: ::Invoice.human_attribute_name(:remarks),
        body: '{{ invoice_part.invoice.remarks }}'
      }
    ].freeze

    column_type :default do
      body do |invoice_part|
        template_variables = {
          'booking' => Manage::BookingSerializer.render_as_hash(invoice_part.booking),
          'invoice_part' => Manage::InvoicePartSerializer.render_as_hash(invoice_part)
        }
        @templates[:body]&.render!(template_variables.transform_values(&:deep_stringify_keys))
      end
    end

    def filter(_period = nil)
      # ::InvoicePart::Filter.new(prefilter_params.merge(paid_at_after: period&.begin, paid_at_before: period&.end))
      # rescue StandardError
      ::InvoicePart::Filter.new
    end

    def base_scope
      @base_scope ||= ::InvoicePart.joins(usage: :tarif, invoice: :booking)
                                   .where(invoices: { bookings: { organisation_id: organisation } })
    end
  end
end
