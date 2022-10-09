class RemoveOrangePaymentSlips < ActiveRecord::Migration[7.0]
  def change
    Invoice.where(payment_info_type: "PaymentInfos::OrangePaymentSlip").find_each do |invoice| 
      invoice.update(payment_info_type: invoice.organisation.default_payment_info_type)
    end
  end
end
