require 'prawn'

module Export
  module Pdf
    class BookingReport < Base
      attr_reader :report

      def initialize(report, _options = {})
        @report = report
      end

      def document_options
        super.merge(
          page_layout: :landscape
        )
      end

      def sections
        [
          Base::LogoSection.new, ->(pdf) { pdf.move_down 40 },
          Base::TitleSection.new(report.label),
          # Base::MarkdownSection.new(Markdown.new(@report.text)),
          TabularDataSection.new(report)
        ]
      end

      class TabularDataSection < Base::Section
        def initialize(report)
          @report = report
        end

        def call(pdf)
          # table_data = @data.map do |data_row|
          #   data_row
          # end

          pdf.table(@report.to_tabular) do
            cells.style(size: 7)
            row(0).font_style = :bold
            # column(2).style(align: :right)
          end
        end
      end
    end
  end
end
