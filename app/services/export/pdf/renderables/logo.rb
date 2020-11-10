# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Logo < Renderable
        def initialize(logo)
          super()
          @logo = logo
        end

        def render
          image_source = @logo.respond_to?(:download) && StringIO.open(@logo.download)
          image_source ||= Rails.root.join('app/webpack/images/logo.png')
          image image_source, at: [bounds.left, bounds.top + 35], width: 100, height: 50, fit: [100, 50]
        end
      end
    end
  end
end
