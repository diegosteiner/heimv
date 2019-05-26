require 'prawn'

module Export
  module Pdf
    class Base
      include Prawn::View

      def document
        @document ||= initialize_document
      end

  def initialize_document
    Prawn::Document.new(document_options).tap do |document|
        fonts_path = File.join(__dir__, '..', 'assets', 'fonts')
        document.font_families.update('OpenSans' => {
                               normal: File.join(fonts_path, 'OpenSans-Regular.ttf'),
                               italic: File.join(fonts_path, 'OpenSans-Italic.ttf'),
                               bold: File.join(fonts_path, 'OpenSans-Bold.ttf'),
                               bold_italic: File.join(fonts_path, 'OpenSans-BoldItalic.ttf')
                             })
        document.font 'OpenSans'
        document.font_size(10)
    end
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

      def build
        sections.each { |section| section.call(document) }
        self
      end
    end
  end
end
