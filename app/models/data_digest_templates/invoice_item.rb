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

module DataDigestTemplates
  class InvoiceItem < Tabular
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Invoice.human_attribute_name(:ref),
        body: '{{ invoice.payment_ref }}'
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
        header: ::Invoice.human_attribute_name(:percentage_paid),
        body: '{{ invoice.percentage_paid }}'
      },
      {
        header: ::Invoice.human_attribute_name(:issued_at),
        body: '{{ invoice.issued_at }}'
      },
      {
        header: ::Tarif.model_name.human,
        body: '{{ invoice_item.usage.tarif_id }}'
      },
      {
        header: ::Tarif.human_attribute_name(:label),
        body: '{{ invoice_item.usage.tarif.label }}'
      },
      {
        header: ::Invoice::Item.human_attribute_name(:label),
        body: '{{ invoice_item.label }}'
      },
      {
        header: ::Invoice::Item.human_attribute_name(:breakdown),
        body: '{{ invoice_item.breakdown }}'
      },
      {
        header: ::Usage.human_attribute_name(:used_units),
        body: '{{ invoice_item.usage.used_units }}'
      },
      {
        header: ::Invoice::Item.human_attribute_name(:amount),
        body: '{{ invoice_item.amount | round: 2 }}'
      },
      {
        header: ::Usage.human_attribute_name(:remarks),
        body: '{{ invoice_item.usage.remarks }}'
      }
    ].freeze

    column_type :default do
      body do |invoice_item, template_context_cache|
        booking = invoice_item.booking
        context = template_context_cache[cache_key(invoice_item.invoice, invoice_item.id)] ||=
          TemplateContext.new(booking:, invoice: invoice_item.invoice,
                              invoice_item:, organisation: booking.organisation).to_h
        @templates[:body]&.render!(context)
      end
    end

    def crunch(records)
      record_ids = records.pluck(:id).uniq
      base_scope.where(id: record_ids).find_each(cursor: record_order.keys,
                                                 order: record_order.values).flat_map do |record|
        record.items.map do |entry|
          template_context_cache = {}
          columns.map { |column| column.body(entry, template_context_cache) }
        end
      end
    end

    def periodfilter(period = nil)
      filter_class.new(issued_at_after: period&.begin, issued_at_before: period&.end)
    end

    def filter_class
      ::Invoice::Filter
    end

    def base_scope
      @base_scope ||= ::Invoice.joins(:booking).where(bookings: { organisation_id: organisation })
                               .includes(booking: :organisation).ordered
    end
  end
end
