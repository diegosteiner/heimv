module Export
  module Pdf
    class Base
      class SenderAddressSection < Section
        def initialize(sender_address)
          @sender_address = sender_address
        end

        def call(pdf)
          pdf.bounding_box [0, 690], width: 200, height: 170 do
            pdf.default_leading 3
            pdf.text 'Vermieter', size: 13, style: :bold
            pdf.move_down 5
            pdf.text 'vertreten durch:', size: 8
            pdf.text @sender_address
          end
        end
      end
    end
  end
end
