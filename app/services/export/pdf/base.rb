# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class Base
      FONTS_PATH = File.join(__dir__, '..', '..', '..', 'webpack', 'fonts')
      include Prawn::View

      def self.add_font_family(name, **options)
        font_families[name.to_s] = options
      end

      def self.font_families
        @font_families ||= superclass.ancestors.include?(Base) && superclass.font_families.dup || {}
      end

      def self.font_size
        @font_size ||= 9
      end

      def self.to_render(_name = nil, &block)
        render_queue << block if block_given?
      end

      def self.render_queue
        @render_queue ||= []
      end

      def render(renderable)
        renderable.render_into(document) if renderable.is_a?(Renderable)
      end

      def render_document
        self.class.render_queue.each { |block| instance_exec(&block) }
        document.render
      end

      add_font_family('OpenSans',
                      normal: File.join(FONTS_PATH, 'OpenSans-Regular.ttf'),
                      italic: File.join(FONTS_PATH, 'OpenSans-Italic.ttf'),
                      bold: File.join(FONTS_PATH, 'OpenSans-Bold.ttf'),
                      bold_italic: File.join(FONTS_PATH, 'OpenSans-BoldItalic.ttf'))

      def document
        @document ||= initialize_document
      end

      def initialize_document
        Prawn::Document.new(document_options).tap do |document|
          document.font_families.update(self.class.font_families)
          document.font('OpenSans')
          document.font_size(self.class.font_size)
          document.default_leading(3)
        end
      end

      def document_options
        {
          page_size: 'A4',
          optimize_objects: true,
          compress: true,
          margin: [75, 60, 50, 60],
          align: :left, kerning: true
        }
      end
    end
  end
end
