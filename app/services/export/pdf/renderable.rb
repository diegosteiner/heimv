module Export
  module Pdf
    class Renderable
      include Prawn::View
      attr_reader :document

      def render_into(document)
        @document = document
        render
      end
    end
  end
end
