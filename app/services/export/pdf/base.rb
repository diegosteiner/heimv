require 'prawn'

module Export
  module Pdf
    class Base
      include Prawn::View

      def document
        @document || initialize_document
      end

      def initialize_document
        @document ||= Prawn::Document.new(document_options)
        initialize_font
        @document
      end

      def document_options
        {
          page_size: 'A4',
          optimize_objects: true,
          compress: true,
          margin: [50] * 4,
          align: :left, kerning: true
        }
      end

      def initialize_font
        font_path = Rails.root.join('app', 'webpack', 'fonts', 'OpenSans-Regular.ttf')
        @document.font_size(10)
        @document.font_families.update('OpenSans' => {
                                         normal: font_path,
                                         italic: font_path,
                                         bold: font_path,
                                         bold_italic: font_path
                                       })
        @document.font 'OpenSans'
      end

      def build
        sections.each { |section| section.call(document) }
        self
      end
    end
  end
end
