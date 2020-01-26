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
      end
    end
  end
end
