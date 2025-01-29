# frozen_string_literal: true

module Export
  module Taf
    class Document
      attr_reader :children

      def initialize(&)
        @children = [] + Builder.build(&)
      end

      def serialize(indent_with: '  ', separate_with: "\n")
        children.filter_map do |block|
          block.serialize(indent_level: 0, indent_with:, separate_with:) if block.is_a?(Block)
        end.join(separate_with + separate_with)
      end

      def to_s
        serialize.encode(Encoding::ISO_8859_1)
      end
    end
  end
end
