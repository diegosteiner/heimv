module Export
  module Pdf
    class Base
      class LogoSection < Section
        def initialize(logo)
          @logo = logo
        end

        def render
          image image_source, at: [bounds.top_left[0], bounds.top_left[1] + 35], width: 120, fit: [120, 100]
        end

        private

        def image_source
          return StringIO.open(@logo.download) if @logo.respond_to?(:download)
          Rails.root.join('app', 'webpack', 'images', 'logo.png')
        end
      end
    end
  end
end
