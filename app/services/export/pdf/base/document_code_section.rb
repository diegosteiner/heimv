module Export
  module Pdf
    class Base
      class DocumentCodeSection
        def initialize(code)
          @code = code
        end

        def call(pdf)
          # pdf.image open('https://thewindowsclub-thewindowsclubco.netdna-ssl.com/wp-content/uploads/2011/11/Barcode.jpg'),
          #           at: [pdf.bounds.top_right[0] - 90, pdf.bounds.top_right[1] + 35],
          #           width: 120
        end
      end
    end
  end
end
