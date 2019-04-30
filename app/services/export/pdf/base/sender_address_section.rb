module Export
  module Pdf
    class Base
      class SenderAddressSection < Section
        def call(pdf)
          pdf.bounding_box [0, 690], width: 200, height: 170 do
            pdf.default_leading 3
            pdf.text 'Vermieter', size: 13, style: :bold
            pdf.move_down 5
            pdf.text 'vertreten durch:', size: 8
            pdf.text "Verein Pfadiheime St. Georg\nHeimverwaltung\nChristian Morger\nGeeringstr. 44\n8049 Zürich"
            pdf.text "\nTel: 079 262 25 48\nEmail: info@pfadi-heime.ch", size: 8
          end
        end
      end
    end
  end
end
