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
#  organisation_id    :bigint           default(1), not null
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
    end

    def formats
      super + [:pdf]
    end

    def records
      @records ||= filter.reduce(::Payment.all)
    end

    protected

    def generate_tabular_header
      [
        ::Payment.human_attribute_name(:ref),
        ::Payment.human_attribute_name(:paid_at),
        ::Payment.human_attribute_name(:amount),
        ::Payment.human_attribute_name(:remarks)
      ]
    end

    def generate_tabular_footer
      []
    end

    def generate_tabular_row(payment)
      payment.instance_eval do
        [
          ref, I18n.l(paid_at, format: :default), amount, remarks
        ]
      end
    end
  end
end
