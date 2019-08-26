require 'prawn'

module Export
  module Pdf
    class DataDigest < Base
      attr_reader :data_digest

      def initialize(data_digest, options = {})
        @data_digest = data_digest
        @options = options
      end

      def document_options
        super.merge(@options.fetch(:document_options, {}))
      end

      def sections
        [
          Base::LogoSection.new, ->(pdf) { pdf.move_down 40 },
          Base::TitleSection.new(data_digest.label),
          # Base::MarkdownSection.new(Markdown.new(@data_digest.text)),
          TabularDataSection.new(data_digest)
        ]
      end

      class TabularDataSection < Base::Section
        def initialize(data_digest)
          @data_digest = data_digest
        end

        def call(pdf)
          table_data = @data_digest.to_tabular

          pdf.table(table_data, column_widths: @data_digest.column_widths) do
            cells.style(size: 10, borders: [])
            row(0).font_style = :bold
            row(0).borders = [:bottom]
          end
        end
      end
    end
  end
end
