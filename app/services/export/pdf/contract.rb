require 'prawn'

module Export
  module Pdf
    class Contract < Base
      def initialize(contract)
        @contract = contract
        @booking = contract.booking
      end

      def sections
        [
          Base::LogoSection.new,
          Base::SenderAddressSection.new,
          Base::RecipientAddressSection.new(@booking),
          Base::TitleSection.new("Mietvertrag: #{@booking.home.name}"),
          Base::MarkdownSection.new(Markdown.new(@contract.text)),
          TarifSection.new(@booking.used_tarifs)
        ]
      end

      class TarifSection < Base::Section
        def initialize(tarifs)
          @tarifs = tarifs
        end

        def call(pdf)
          return if @taris.blank?

          table_data = @tarifs.map do |tarif|
            [tarif.label, tarif.unit, format('CHF %.2f', tarif.price_per_unit)]
          end

          pdf.table table_data, column_widths: [200, 200, 94], cell_style: {} do
            cells.style(size: 10)
            column(2).style(align: :right)
          end
        end
      end
    end
  end
end
