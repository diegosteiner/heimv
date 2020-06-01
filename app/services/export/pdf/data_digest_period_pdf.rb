require 'prawn'

module Export
  module Pdf
    class DataDigestPeriodPdf < Base
      attr_reader :data_digest_period, :organisation

      def initialize(data_digest_period, options = {})
        @data_digest_period = data_digest_period
        @options = options
        @organisation = data_digest_period.data_digest.organisation
      end

      def document_options
        super.merge(@options.fetch(:document_options, {}))
      end

      to_render do 
        render Renderables::Logo.new(organisation.logo)
        render Renderables::Title.new(data_digest_period.data_digest.label)
      end

      to_render do
        table_data = [@data_digest_period.data_header] + @data_digest_period.data
        column_widths = @options[:column_widths] || {}

        table(table_data, column_widths: column_widths) do
          cells.style(size: 8, borders: [])
          row(0).font_style = :bold
          row(0).borders = [:bottom]
        end
      end
    end
  end
end
