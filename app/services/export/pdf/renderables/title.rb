# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Title < Renderable
        def initialize(title, size: 18)
          @title = title
          @size = size
        end

        def render
          move_down @size
          text @title, size: @size, style: :bold
        end
      end
    end
  end
end
