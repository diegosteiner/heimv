module Pdf
  module Sections
    class TitleSection
      def initialize(title)
        @title = title
      end

      def call(pdf)
        pdf.move_down 20
        pdf.text @title, size: 20, style: :bold
      end
    end
  end
end
