# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class DataDigestPdf < Base
      attr_reader :data_digest

      def initialize(data_digest, options = {})
        super()
        @data_digest = data_digest
        @options = options
        @organisation = data_digest.organisation
      end

      def document_options
        super.merge(@options.fetch(:document_options, {}))
      end

      to_render do
        render Renderables::PageHeader.new(text: data_digest.label, logo: @organisation.logo)
        render Renderables::Title.new(data_digest.label)
      end

      to_render do
        text(data_digest.localized_period, size: 8)
        move_down 10
      end

      to_render do
        table_data = [data_digest.header] + data_digest.data
        table(table_data, width: bounds.width) do
          cells.style(size: 6, borders: [])
          row(0).font_style = :bold
          row(0).borders = [:bottom]
        end
      end
    end
  end
end
