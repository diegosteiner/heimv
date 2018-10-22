module Pdf
  class Base
    class RecipientAddressSection < Section
      def initialize(booking)
        @booking = booking
      end

      def call(pdf)
        pdf.bounding_box [300, 690], width: 200, height: 170 do
          pdf.default_leading 4
          pdf.text 'Mieter', size: 13, style: :bold
          pdf.move_down 5
          pdf.text @booking.ref, size: 9
          pdf.text @booking.organisation, size: 9
          pdf.text @booking.tenant.address_lines.join("\n"), size: 11
        end
      end
    end
  end
end
