# frozen_string_literal: true

module PaymentInfos
  class OnArrival < ::PaymentInfo
    ::PaymentInfo.register_subtype self
  end
end
