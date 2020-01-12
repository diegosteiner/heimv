require 'prawn'

module Export
  module Pdf
    class Contract < Base
      def initialize(contract)
        @contract = contract
        @booking = contract.booking
        @organisation = @booking.organisation
      end

      def sections
        [
          Base::LogoSection.new(@organisation.logo),
          Base::SenderAddressSection.new(@booking),
          Base::RecipientAddressSection.new(@booking),
          Base::MarkdownSection.new(Markdown.new(@contract.text)),
          TarifSection.new(@booking.used_tarifs), SignatureSection.new(@contract)
        ]
      end

      class TarifSection < Base::Section
        def initialize(tarifs)
          @tarifs = tarifs
        end

        def render
          return if @tarifs.blank?

          table([row_headers] + table_data(@tarifs), column_widths: [200, 200, 94]) do
            rows(0).style(font_style: :bold)
            cells.style(size: 10, borders: [])
            column(2).style(align: :right)
          end
        end

        def table_data(tarifs)
          tarifs.map do |tarif|
            [tarif.label, tarif.unit, format('CHF %<price>.2f', price: tarif.price_per_unit)]
          end
        end

        def row_headers
          [Tarif.model_name.human, Tarif.human_attribute_name(:unit), Tarif.human_attribute_name(:price_per_unit)]
        end
      end

      class SignatureSection < Base::Section
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
          [@organisation.contract_location, I18n.l(contract.created_at || Time.zone.today)].join(', ')
        end

        def signature_image_source
          StringIO.open(organisation.contract_signature.download) if organisation.contract_signature.present?
        end

        def render_signature_box(at, signature_label, date_place = ' ', image_source = nil)
          signature_height = 60

          bounding_box(at, width: signature_box_width, height: 120) do
            text(date_place)
            image_source.present? ? image(image_source, height: signature_height) : move_down(signature_height)
            text('_______________________________________________')
            text(signature_label, size: 8)
          end
        end
      end
    end
  end
end
