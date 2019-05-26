module Reports
class PaymentReport < Report
  def filter
    @filter ||= Payment::Filter.new(filter_params)
  end

  def formats
    super + [:pdf]
  end

  def records
    @records ||= filter.reduce(Payment.all)
  end

  protected

  def generate_tabular_header
    [
      Payment.human_attribute_name(:ref), Payment.human_attribute_name(:paid_at), Payment.human_attribute_name(:amount)
    ]
  end

  def generate_tabular_footer
    []
  end

  def generate_tabular_row(payment)
    payment.instance_eval do
      [
        ref, I18n.l(paid_at, format: :short), amount
      ]
    end
  end
end
end
