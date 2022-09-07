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
  class Payment < DataDigest
    ::DataDigest.register_subtype self

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
      body do |payment|
        booking = payment.booking
        context = TemplateContext.new(booking: booking, organisation: booking.organisation,
                                      home: booking.home, payment: payment)
        @templates[:body]&.render!(context.cached)
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
