module Export
  module Pdf
    module Renderables
      class Title < Renderable
        def initialize(title, size: 20)
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
