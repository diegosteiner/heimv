module Export
  module Pdf
    module Renderables
      class Signatures < Renderable
        GAP = 20
        attr_reader :contract, :organisation

        def initialize(contract)
          @contract = contract
          @organisation = contract.booking.organisation
        end

        def render
          bounding_box([0, y - 100], height: 120, width: bounds.width) do
            render_signature_box([0, bounds.top], 'Datum, Unterschrift Vermieter',
                                 renting_party_date_place, signature_image_source)
            render_signature_box([signature_box_width + GAP, bounds.top], 'Datum, Unterschrift Mieter')
          end
        end

        protected

        def render_renting_party_signature_box; end

        def signature_box_width
          @signature_box_width ||= (bounds.width - GAP) / 2
        end

        def renting_party_date_place
          [@organisation.contract_location, I18n.l(contract.created_at&.to_date || Time.zone.today)].join(', ')
        end

        def signature_image_source
          StringIO.open(organisation.contract_signature.download) if organisation.contract_signature.present?
        end

        def render_signature_box(at, signature_label, date_place = ' ', image_source = nil)
          signature_height = 60

          bounding_box(at, width: signature_box_width, height: 120) do
            text(date_place)
            image_source.present? ? image(image_source, height: signature_height) : move_down(signature_height)
            stroke_horizontal_rule
            move_down 2
            text(signature_label, size: 8)
          end
        end
      end
    end
  end
end
