require 'prawn'

module Export
  module Pdf
    class BookingReport < Base
      attr_reader :report

      def initialize(report, options = {})
        @report = report
        @options = options
      end

      def document_options
        super.merge(@options.fetch(:document_options, {}))
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
          table_data = @report.to_tabular do |row|
            row.map do |value|
              case value
              when ActiveSupport::TimeWithZone
              else
                value
              end
            end
          end

          pdf.table(table_data) do
            cells.style(size: 8)
            row(0).font_style = :bold
            # column(2).style(align: :right)
          end
        end
      end
    end
  end
end
