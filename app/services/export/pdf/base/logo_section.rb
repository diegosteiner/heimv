module Export
  module Pdf
    class Base
      class LogoSection
        def call(pdf)
          pdf.image image_source, at: [pdf.bounds.top_left[0], pdf.bounds.top_left[1] + 35], width: 120, fit: [120, 100]
        end

        private

        def image_source
          if Organisation.instance.logo.attached?
            StringIO.open(Organisation.instance.logo.download)
          else
            Rails.root.join('app', 'webpack', 'images', 'logo.png')
          end
        end
      end
    end
  end
end
