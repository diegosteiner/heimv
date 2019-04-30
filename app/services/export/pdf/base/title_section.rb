module Export
  module Pdf
    class Base
      class TitleSection
        def initialize(title)
          @title = title
        end

        def call(pdf)
          pdf.move_down 10
          pdf.text @title, size: 20, style: :bold
        end
      end
    end
  end
end
