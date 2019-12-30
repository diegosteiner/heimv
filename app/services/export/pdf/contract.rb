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
          Base::SenderAddressSection.new(@organisation.contract_representative_address || @organisation.address),
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

          table_data = @tarifs.map do |tarif|
            [tarif.label, tarif.unit, format('CHF %<price>.2f', price: tarif.price_per_unit)]
          end

          table table_data, column_widths: [200, 200, 94], cell_style: {} do
            cells.style(size: 10)
            column(2).style(align: :right)
          end
        end
      end

      class SignatureSection < Base::Section
        attr_reader :contract, :organisation

        def initialize(contract)
          @contract = contract
          @organisation = contract.booking.organisation
        end

        def render
          move_down 100
          gap = 20
          width = (bounds.width - gap) / 2
          cursor_y = y

          render_signature_box([0, cursor_y], width, 'Datum, Unterschrift Vermieter', "Zürich,
            #{I18n.l(Time.zone.today)}", contract_signature_image_source)
          render_signature_box([width + gap, cursor_y], width, 'Datum, Unterschrift Mieter')
        end

        protected

        def contract_signature_image_source
          StringIO.open(organisation.contract_signature.download) if organisation.contract_signature.present?
        end

        def render_signature_box(at, width, label, date_place = ' ', image_source = nil)
          signature_height = 60
          bounding_box(at, width: width) do
            text(date_place)
            image_source.present? ? image(image_source, height: signature_height) : move_down(signature_height)
            text('_______________________________________________')
            text(label, size: 8)
          end
        end
      end
    end
  end
end
