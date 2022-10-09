class RemoveOrangePaymentSlips < ActiveRecord::Migration[7.0]
  def up
    Organisation.find_each do |organisation|
        Invoice.where(payment_info_type: "PaymentInfos::OrangePaymentSlip")
               .joins(:booking).where(booking: { organisation: organisation })
               .update_all(payment_info_type: organisation.default_payment_info_type)
    end
  end
end
