# frozen_string_literal: true

module Export
  module Taf
    class Document
      attr_reader :blocks

      def initialize(blocks = nil, &)
        @blocks = [blocks, (Builder.new(&).blocks if block_given?)].compact.flatten
      end

      def serialize(indent_with: '  ', separate_with: "\n")
        @blocks.map do |block|
          block.serialize(indent_level: 0, indent_with:, separate_with:) if block.is_a?(Block)
        end.compact.join(separate_with + separate_with)
      end

      def to_s
        serialize
      end
    end
  end
end
