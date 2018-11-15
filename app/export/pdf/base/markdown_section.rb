module Pdf
  class Base
    class MarkdownSection < Section
      def initialize(markdown)
        @markdown = markdown
      end

      def call(pdf)
        pdf.move_down 10
        @markdown.to_pdf.each do |body|
          pdf.text body.delete(:text), body.reverse_merge(inline_format: true, size: 10)
        end
      end
    end
  end
end
