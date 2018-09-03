require 'prawn'

module PDF
  class Contract
    include Prawn::View

    def initialize(contract)
      @contract = contract
      @markdown = MarkdownService.new(contract.text)
    end

    def document
      @document ||= Prawn::Document.new(
        page_size: 'A4',
        optimize_objects: true,
        margin: [50] * 4
      )
    end

    def build
      build_header
      build_addresses

      move_down 20
      text "Mietvertrag: #{@contract.booking.home.name}", size: 20, style: :bold

      move_down 10
      formatted_text @markdown.pdf_body(janitor: @contract.booking.home.janitor), inline_format: true, size: 10

      move_down 10
      build_tarifs

      self
    end

    def build_header
      image Rails.root.join('app', 'webpack', 'images', 'logo_hvs.png'),
            at: [bounds.top_left[0] - 25, bounds.top_left[1] + 35],
            width: 120
    end

    def build_tarifs
      table_data = @contract.booking.used_tarifs.map do |tarif|
        [tarif.label, tarif.unit, 'CHF %.2f' % tarif.price_per_unit]
      end

      table table_data do
        cells.style(size: 10)
      end

    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def build_addresses
      bounding_box [0, 670], width: 200, height: 170 do
        default_leading 3
        text 'Vermieter', size: 16, style: :bold
        move_down 5
        text 'vertreten durch:', size: 9
        text "Verein Pfadiheime St. Georg\nHeimverwaltung\nChristian Morger\nGeeringstr. 44\n8049 Zürich", size: 10
        text "\nTel: 079 262 25 48\nEmail: info@pfadi-heime.ch", size: 9
      end

      bounding_box [300, 670], width: 200, height: 170 do
        default_leading 4
        text 'Mieter', size: 16, style: :bold
        move_down 5
        text @contract.booking.ref, size: 9
        text @contract.booking.organisation, size: 9
        text @contract.booking.customer.address_lines.join("\n"), size: 11
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
