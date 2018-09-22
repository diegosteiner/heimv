module Pdf
  module Sections
    class SenderAddressSection < Section
      def call(pdf)
        pdf.instance_eval do
          bounding_box [0, 690], width: 200, height: 170 do
            default_leading 3
            text 'Vermieter', size: 13, style: :bold
            move_down 5
            text 'vertreten durch:', size: 9
            text "Verein Pfadiheime St. Georg\nHeimverwaltung\nChristian Morger\nGeeringstr. 44\n8049 Zürich", size: 10
            text "\nTel: 079 262 25 48\nEmail: info@pfadi-heime.ch", size: 9
          end
        end
      end
    end
  end
end
