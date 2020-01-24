module Export
  module Pdf
    class Base
      class Section
        include Prawn::View
        attr_reader :document

        def render_in(document)
          @document = document
          render
        end
      end
    end
  end
end
