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
        body: '{{ payment.booking.ref }}'
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
        body: "{{ payment.booking.tenant.full_address_lines | join: \"\n\" }}"
      },
      {
        header: ::Payment.human_attribute_name(:remarks),
        body: '{{ payment.remarks }}'
      }
    ].freeze

    column_type :default do
      body do |payment|
        @templates[:body]&.render!('payment' => payment)
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

    protected

    def build_header
      [
        ::Booking.human_attribute_name(:ref)
      ]
    end

    def build_data_row(payment)
      payment.instance_eval do
        [
          ref, payment.booking.ref, I18n.l(paid_at, format: :default), amount, payment.booking.tenant.full_name, remarks
        ]
      end
    end
  end
end
