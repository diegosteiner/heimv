# frozen_string_literal: true

module Export
  module Taf
    class Document
      attr_reader :children

      def initialize(&)
        @children = [] + Builder.build(&)
      end

      def serialize(indent_with: '  ', separate_with: "\n")
        children.map do |block|
          block.serialize(indent_level: 0, indent_with:, separate_with:) if block.is_a?(Block)
        end.compact.join(separate_with + separate_with)
      end

      def to_s
        serialize
      end
    end
  end
end
