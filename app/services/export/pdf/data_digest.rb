require 'prawn'

module Export
  module Pdf
    class DataDigest < Base
      attr_reader :data_digest

      def initialize(data_digest, organisation, options = {})
        @data_digest = data_digest
        @options = options
        @organisation = organisation
      end

      def document_options
        super.merge(@options.fetch(:document_options, {}))
      end

      def sections
        [
          Base::LogoSection.new(@organisation.logo),
          Base::TitleSection.new(data_digest.label, 60),
          # Base::MarkdownSection.new(Markdown.new(@data_digest.text)),
          TabularDataSection.new(data_digest)
        ]
      end

      class TabularDataSection < Base::Section
        def initialize(data_digest)
          @data_digest = data_digest
        end

        def render
          table_data = @data_digest.to_tabular

          table(table_data, column_widths: @data_digest.column_widths) do
            cells.style(size: 8, borders: [])
            row(0).font_style = :bold
            row(0).borders = [:bottom]
          end
        end
      end
    end
  end
end
