require 'prawn'

module PDF
  class Contract < DocumentWithAddress
    def initialize(contract)
      @contract = contract
      @booking = contract.booking
      @title = "Mietvertrag: #{@booking.home.name}"
    end

    part :body do
      move_down 10
      markdown = MarkdownService.new(@contract.text)
      interpolation_arguments = HashFlattener.call(ContractSerializer.new(@contract).serializable_hash(include: 'booking.occupancy,booking.customer,booking.home'))
      markdown.pdf_body(interpolation_arguments).each do |body|
        text body.delete(:text), body.reverse_merge(inline_format: true, size: 10)
      end
    end

    part :tarifs do
      table_data = @contract.booking.used_tarifs.map do |tarif|
        [tarif.label, tarif.unit, format('CHF %.2f', tarif.price_per_unit)]
      end

      table table_data, column_widths: [200, 200, 94] do
        cells.style(size: 10)
      end
    end
  end
end
