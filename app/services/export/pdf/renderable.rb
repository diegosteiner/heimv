# frozen_string_literal: true

module Export
  module Pdf
    class Renderable
      include Prawn::View
      attr_reader :document

      def initialize(&block)
        @block = block
      end

      def render
        raise NotImplemented if @block.nil?

        instance_exec(&@block)
      end

      def render_into(document)
        @document = document
        render
      end
    end
  end
end
