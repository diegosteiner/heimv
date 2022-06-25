# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  columns            :jsonb
#  data_digest_params :jsonb
#  label              :string
#  prefilter_params   :jsonb
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
    ::DataDigest.register_subtype self

    def prefilter
      @prefilter ||= ::Payment::Filter.new(prefilter_params)
    rescue StandardError
      ::Payment::Filter.new
    end

    def base_scope
      @base_scope ||= organisation.payments.ordered
    end

    def period_filter(period)
      ::Payment::Filter.new(paid_at_after: period.begin, paid_at_before: period.end)
    end

    protected

    def build_header
      [
        ::Payment.human_attribute_name(:ref),
        ::Booking.human_attribute_name(:ref),
        ::Payment.human_attribute_name(:paid_at),
        ::Payment.human_attribute_name(:amount),
        ::Tenant.model_name.human,
        ::Payment.human_attribute_name(:remarks)
      ]
    end

    def build_data_row(payment)
      payment.instance_eval do
        [
          ref, booking.ref, I18n.l(paid_at, format: :default), amount, booking.tenant.full_name, remarks
        ]
      end
    end
  end
end
