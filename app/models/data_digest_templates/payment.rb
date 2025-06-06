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
  class Payment < Tabular
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Payment.human_attribute_name(:ref),
        body: '{{ payment.invoice.payment_ref }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      },
      {
        header: ::Payment.human_attribute_name(:paid_at),
        body: '{{ payment.paid_at | datetime_format }}'
      },
      {
        header: ::Payment.human_attribute_name(:amount),
        body: '{{ payment.amount | round: 2 }}'
      },
      {
        header: ::Tenant.model_name.human,
        body: "{{ booking.tenant.full_address_lines | join: \"\n\" }}"
      },
      {
        header: ::Payment.human_attribute_name(:remarks),
        body: '{{ payment.remarks }}'
      }
    ].freeze

    column_type :default do
      body do |payment, template_context_cache|
        booking = payment.booking
        context = template_context_cache[cache_key(payment)] ||=
          TemplateContext.new(booking:, organisation: booking.organisation, payment:).to_h
        @templates[:body]&.render!(context)
      end
    end

    def periodfilter(period = nil)
      filter_class.new(paid_at_after: period&.begin, paid_at_before: period&.end)
    end

    def filter_class
      ::Payment::Filter
    end

    def record_order
      { created_at: :asc, id: :asc }
    end

    def base_scope
      @base_scope ||= organisation.payments.includes(:invoice, booking: :organisation).order(paid_at: :ASC)
    end
  end
end
