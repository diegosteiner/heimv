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
  class Payment < DataDigestTemplate
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Payment.human_attribute_name(:ref),
        body: '{{ payment.invoice.ref }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      },
      {
        header: ::Payment.human_attribute_name(:paid_at),
        body: '{{ payment.paid_at }}'
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
      body do |payment, tempalte_context_cache|
        booking = payment.booking
        context = tempalte_context_cache[cache_key(payment)] ||=
          TemplateContext.new(booking: booking, organisation: booking.organisation, payment: payment).to_h
        @templates[:body]&.render!(context)
      end
    end

    def filter(period = nil)
      ::Payment::Filter.new(prefilter_params.merge(paid_at_after: period&.begin, paid_at_before: period&.end))
    rescue StandardError
      ::Payment::Filter.new
    end

    def base_scope
      @base_scope ||= organisation.payments.ordered
    end
  end
end
