module Export
  module Pdf
    class Base
      class TitleSection < Section
        def initialize(title)
          @title = title
        end

        def render
          move_down 10
          text @title, size: 20, style: :bold
        end
      end
    end
  end
end
