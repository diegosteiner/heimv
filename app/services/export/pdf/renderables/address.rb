# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Address < Renderable
        attr_reader :address, :options

        def initialize(address, represented_by: nil, column: :left, height: 120, label: nil)
          super()
          @address = Array.wrap(address).flatten.compact.map(&:strip).compact_blank
          @represented_by = Array.wrap(represented_by).flatten.compact.map(&:strip).compact_blank
          @column = column
          @height = height || 120
          @label = label
        end

        def render
          bounding_box [x_position, y_position], width: 200, height: @height do
            text @label, size: 10, style: :bold if @label
            move_down 5

            text @address&.join("\n") || ''
            move_down 5

            render_represented_by if @represented_by.present?
          end
        end

        private

        def render_represented_by
          text I18n.t('contracts.represented_by'), size: 7
          move_down 5
          text @represented_by&.join("\n") || ''
        end

        def x_position
          @column == :right ? 300 : 0
        end

        def y_position
          690
        end
      end
    end
  end
end
