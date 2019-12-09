module PaymentInfos
  def self.types
    # constants.select { |klass| const_get(klass).is_a?(Class) }
    [OrangePaymentSlip, TextPaymentInfo]
  end
end
