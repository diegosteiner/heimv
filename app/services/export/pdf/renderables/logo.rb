module Export
  module Pdf
    module Renderables
      class Logo < Renderable
        def initialize(logo)
          @logo = logo
        end

        def render
          image_source = @logo.respond_to?(:download) && StringIO.open(@logo.download)
          image_source ||= Rails.root.join('app/webpack/images/logo.png')
          image image_source, at: [bounds.left, bounds.top + 35], width: 120, fit: [120, 100]
        end
      end
    end
  end
end
