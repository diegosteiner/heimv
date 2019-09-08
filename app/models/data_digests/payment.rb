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
