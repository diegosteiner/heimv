require 'prawn'

class ContractPdf < AddressedPdf
  def initialize(contract)
    @contract = contract
    @booking = contract.booking
    @title = "Mietvertrag: #{@booking.home.name}"
  end

  part :body do
    move_down 10
    markdown = MarkdownService.new(@contract.text)
    markdown.pdf_body(InterpolationService.call(@contract)).each do |body|
      text body.delete(:text), body.reverse_merge(inline_format: true, size: 10)
    end
  end

  part :tarifs do
    table_data = @contract.booking.used_tarifs.map do |tarif|
      [tarif.label, tarif.unit, format('CHF %.2f', tarif.price_per_unit)]
    end

    table table_data, column_widths: [200, 200, 94], cell_style: {} do
      cells.style(size: 10)
      column(2).style(align: :right)
    end
  end
end
