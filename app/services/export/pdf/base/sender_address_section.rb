module Export
  module Pdf
    class Base
      class SenderAddressSection < Section
        def initialize(sender_address)
          @sender_address = sender_address
        end

        def render
          bounding_box [0, 690], width: 200, height: 170 do
            default_leading 3
            text 'Vermieter', size: 13, style: :bold
            move_down 5
            text 'vertreten durch:', size: 8
            text @sender_address
          end
        end
      end
    end
  end
end
