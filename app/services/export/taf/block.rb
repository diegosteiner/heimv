# frozen_string_literal: true

module Export
  module Taf
    class Block
      INDENTOR = '  '
      SEPARATOR = "\n"

      attr_reader :type, :properties, :children

      def initialize(type, children = [], **properties)
        @type = type
        @properties = properties.transform_values { Value.cast(_1) }
        @children = children
      end

      def serialize(indent_level: 0, indent_with: '  ', separate_with: "\n")
        indent = [indent_with * indent_level].join
        separate_and_indent = [separate_with, indent, indent_with].join
        serialized_children = serialize_children(indent_level:, indent_with:, separate_with:)
        serialized_properties = properties.compact.map { |key, value| "#{key}=#{value.serialize}" }

        [ # tag_start
          indent, "{#{type}",
          # properties
          separate_and_indent, serialized_properties.join(separate_and_indent), separate_with,
          # children
          (separate_with if children.present?), serialized_children,
          # tag end
          separate_with, indent, '}'
        ].compact.join
      end

      def serialize_children(indent_level: 0, indent_with: '  ', separate_with: "\n")
        children.map do |child|
          child.serialize(indent_level: indent_level + 1, indent_with:, separate_with:) if child.is_a?(Block)
        end.compact.join(separate_with + separate_with)
      end

      def to_s
        serialize
      end
    end
  end
end
