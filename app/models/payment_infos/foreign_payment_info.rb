module PaymentInfos
  class ForeignPaymentInfo < TextPaymentInfo
    protected

    def markdown_template
      @markdown_template ||= MarkdownTemplate[:foreign_payment_info_text]
    end
  end
end
