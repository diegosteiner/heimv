# frozen_string_literal: true

require 'prawn'

module Export
  module Pdf
    class DataDigestPeriodPdf < Base
      attr_reader :data_digest_period, :organisation

      def initialize(data_digest_period, options = {})
        super()
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
        from = data_digest_period.period_range.begin
        to = data_digest_period.period_range.end
        text([
          (from && I18n.t('data_digests.period_from', date: I18n.l(from))),
          (to && I18n.t('data_digests.period_to', date: I18n.l(to)))
        ].compact.join(' '), size: 8)
        move_down 10
      end

      to_render do
        table_data = [@data_digest_period.data_header] + @data_digest_period.data
        table(table_data, width: bounds.width) do
          cells.style(size: 8, borders: [])
          row(0).font_style = :bold
          row(0).borders = [:bottom]
        end
      end
    end
  end
end
