require 'prawn'

module Pdf
  class ContractPdf < BasePdf
    def initialize(contract)
      @contract = contract
      @booking = contract.booking
    end

    def sections
      [
        Sections::HeaderSection.new,
        Sections::SenderAddressSection.new,
        Sections::RecipientAddressSection.new(@booking),
        Sections::TitleSection.new("Mietvertrag: #{@booking.home.name}"),
        Sections::MarkdownSection.new(@contract.text, InterpolationService.call(@contract)),
        TarifSection.new(@booking.used_tarifs)
      ]
    end

    class TarifSection < Sections::Section
      def initialize(tarifs)
        @tarifs = tarifs
      end

      def call(pdf)
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
