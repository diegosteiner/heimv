# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class PageHeader < Renderable
        def initialize(text: '', logo: nil, repeat: :all)
          super()
          @text = text
          @logo = logo
          @repeat = repeat
        end

        def render
          repeat @repeat do
            render_logo unless @logo == false
            render_text
          end
        end

        def render_text
          width = bounds.width / 2
          bounding_box [bounds.right - width, bounds.top + 55], width:, height: 50 do
            text @text, align: :right, size: 7 if @text.present? || @text.nil?
          end
        end

        def render_logo
          image_source = @logo.respond_to?(:download) && StringIO.open(@logo.download)
          image_source ||= Rails.root.join('app/javascript/images/logo.png')

          image image_source, at: [bounds.left, bounds.top + 80], width: 200, height: 45, fit: [200, 45]
        end
      end
    end
  end
end
