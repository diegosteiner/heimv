# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  data_digest_params :jsonb
#  filter_params      :jsonb
#  label              :string
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
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
    def filter
      @filter ||= ::Payment::Filter.new(filter_params)
    rescue StandardError
      ::Payment::Filter.new
    end

    def scope
      filter.apply(organisation.payments.ordered)
    end

    class Period < DataDigest::Period
      def filter
        @filter ||= ::Payment::Filter.new(paid_at_after: period_range.begin, paid_at_before: period_range.end)
      end

      def filtered
        @filtered ||= filter.apply(@data_digest.scope)
      end

      def data_header
        [
          ::Payment.human_attribute_name(:ref),
          ::Booking.human_attribute_name(:ref),
          ::Payment.human_attribute_name(:paid_at),
          ::Payment.human_attribute_name(:amount),
          ::Tenant.model_name.human,
          ::Payment.human_attribute_name(:remarks)
        ]
      end

      def data_row(payment)
        payment.instance_eval do
          [
            ref, booking.ref, I18n.l(paid_at, format: :default), amount, booking.tenant.name, remarks
          ]
        end
      end
    end
  end
end
