module Export
  module Pdf
    class Base
      class RecipientAddressSection < Section
        def initialize(booking)
          @booking = booking
          @address = @booking.invoice_address.presence || @booking.tenant.address_lines.join("\n")
        end

        def render
          bounding_box [300, 690], width: 200, height: 140 do
            default_leading 4
            text Tenant.model_name.human(count: :one), size: 13, style: :bold
            move_down 5
            text @booking.ref, size: 9
            text @booking.tenant_organisation, size: 9
            text @address, size: 11
          end
        end
      end
    end
  end
end
