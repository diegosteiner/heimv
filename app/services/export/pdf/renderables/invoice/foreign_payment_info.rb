module Export
  module Pdf
    module Renderables
      module Invoice
        class ForeignPaymentInfo < TextPaymentInfo
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
end
