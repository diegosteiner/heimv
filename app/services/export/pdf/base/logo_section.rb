module Export
  module Pdf
    class Base
      class LogoSection
        def initialize(organisation)
          @organisation = organisation
        end

        def call(pdf)
          pdf.image image_source, at: [pdf.bounds.top_left[0], pdf.bounds.top_left[1] + 35], width: 120, fit: [120, 100]
        end

        private

        def image_source
          if @organisation.logo.attached?
            StringIO.open(@organisation.logo.download)
          else
            Rails.root.join('app', 'webpack', 'images', 'logo.png')
          end
        end
      end
    end
  end
end
