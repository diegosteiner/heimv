module Pdf
  module Sections
    class HeaderSection
      def call(pdf)
        pdf.image Rails.root.join('app', 'webpack', 'images', 'logo_hvs.png'),
                  at: [pdf.bounds.top_left[0], pdf.bounds.top_left[1] + 35],
                  width: 120
      end
    end
  end
end
