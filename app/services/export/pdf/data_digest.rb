require 'prawn'

module Export
  module Pdf
    class DataDigest < Base
      attr_reader :data_digest_period

      def initialize(data_digest_period, options = {})
        @data_digest_period = data_digest_period
        @options = options
        @organisation = data_digest_period.data_digest.organisation
      end

      def document_options
        super.merge(@options.fetch(:document_options, {}))
      end

      def sections
        [
          Base::LogoSection.new(@organisation.logo),
          Base::TitleSection.new(data_digest_period.data_digest.label, 60),
          # Base::MarkdownSection.new(Markdown.new(@data_digest_period.text)),
          TabularDataSection.new(data_digest_period, column_widths: @options[:column_widths])
        ]
      end

      class TabularDataSection < Base::Section
        def initialize(data_digest_period, column_widths: [])
          @data_digest_period = data_digest_period
          @column_widths = column_widths
        end

        def render
          table_data = [@data_digest_period.data_header] + @data_digest_period.data

          table(table_data, column_widths: @column_widths) do
            cells.style(size: 8, borders: [])
            row(0).font_style = :bold
            row(0).borders = [:bottom]
          end
        end
      end
    end
  end
end
