# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Signature < Renderable
        def initialize(label = '', signature_image: nil, date: nil, location: nil, align: :left)
          super()
          @label = label
          @date = date
          @location = location
          @align = align
          @signature_image = signature_image
        end

        def render
          bounding_box(at, width: width, height: 120) do
            text([@location.presence, signature_date].compact.join(', ') || ' ')
            signature
            stroke_horizontal_rule
            move_down 2
            text(@label, size: 7)
          end
        end

        protected

        def signature_date
          @date.presence && I18n.l(@date.to_date)
        end

        def signature
          return image(signature_image_source, height: signature_height) if signature_image_source.present?

          move_down(signature_height)
        end

        def at
          return [bounds.right - width, bounds.top] if @align == :right

          [bounds.left, bounds.top]
        end

        def label
          # TODO: i18n
        end

        def width(gap = 20)
          @width ||= (bounds.width - gap) / 2
        end

        def signature_height
          60
        end

        def signature_image_source
          StringIO.open(@signature_image.download) if @signature_image.present?
        end
      end
    end
  end
end
