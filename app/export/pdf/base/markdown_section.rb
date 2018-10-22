module Pdf
  class Base
    class MarkdownSection < Section
      def initialize(markdown, interpolation_arguments)
        @markdown_service = MarkdownService.new(markdown)
        @interpolation_arguments = interpolation_arguments
      end

      def call(pdf)
        pdf.move_down 10
        @markdown_service.pdf_body(@interpolation_arguments).each do |body|
          pdf.text body.delete(:text), body.reverse_merge(inline_format: true, size: 10)
        end
      end
    end
  end
end
