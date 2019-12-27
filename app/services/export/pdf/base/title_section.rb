module Export
  module Pdf
    class Base
      class TitleSection < Section
        def initialize(title, margin_top = 10)
          @title = title
          @margin_top = margin_top
        end

        def render
          move_down @margin_top
          text @title, size: 20, style: :bold
        end
      end
    end
  end
end
