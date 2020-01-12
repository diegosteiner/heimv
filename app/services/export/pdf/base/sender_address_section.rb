module Export
  module Pdf
    class Base
      class SenderAddressSection < Section
        def initialize(booking)
          @organisation = booking.organisation
        end

        def address
          return @organisation.representative_address if representative_address?

          @organisation.address
        end

        def representative_address?
          @organisation.representative_address.present?
        end

        def render
          bounding_box [0, 690], width: 200, height: 170 do
            default_leading 3
            text 'Vermieter', size: 13, style: :bold
            move_down 5
            text 'vertreten durch:', size: 8 if representative_address?
            text @sender_address
          end
        end
      end
    end
  end
end
