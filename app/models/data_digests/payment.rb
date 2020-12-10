# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
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
    def prefilter
      @prefilter ||= ::Payment::Filter.new(prefilter_params)
    rescue StandardError
      ::Payment::Filter.new
    end

    def scope
      @scope ||= filter.apply(organisation.payments.ordered)
    end

    protected

    def build_data(period, _options)
      filter = ::Payment::Filter.new(paid_at_after: period.begin, paid_at_before: period.end)
      filter.apply(scope).map { |payment| build_data_row(payment) }
    end

    def build_header(_period, _options)
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
          ref, booking.ref, I18n.l(paid_at, format: :default), amount, booking.tenant.name, remarks
        ]
      end
    end
  end
end
