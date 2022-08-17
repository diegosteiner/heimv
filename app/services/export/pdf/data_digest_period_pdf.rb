# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class DataDigestPeriodPdf < Base
      attr_reader :periodic_data, :organisation

      def initialize(periodic_data, options = {})
        super()
        @periodic_data = periodic_data
        @options = options
        @organisation = periodic_data.data_digest.organisation
      end

      def document_options
        super.merge(@options.fetch(:document_options, {}))
      end

      to_render do
        render Renderables::PageHeader.new(text: periodic_data.data_digest.label, logo: @organisation.logo)
        render Renderables::Title.new(periodic_data.data_digest.label)
      end

      to_render do
        from = periodic_data.period.begin
        to = periodic_data.period.end
        text([
          (from && I18n.t('data_digests.period_from', date: I18n.l(from))),
          (to && I18n.t('data_digests.period_to', date: I18n.l(to)))
        ].compact.join(' '), size: 8)
        move_down 10
      end

      to_render do
        table_data = [@periodic_data.header] + @periodic_data.rows
        table(table_data, width: bounds.width) do
          cells.style(size: 8, borders: [])
          row(0).font_style = :bold
          row(0).borders = [:bottom]
        end
      end
    end
  end
end
