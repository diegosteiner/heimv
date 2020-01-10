module Export
  module Pdf
    class Invoice
      class ForeignPaymentInfoSection < TextPaymentInfoSection
        protected

        def height
          200
        end

        def font_size
          8
        end

        def markdown_template
          @markdown_template ||= MarkdownTemplate[:foreign_payment_info_text]
        end
      end
    end
  end
end
