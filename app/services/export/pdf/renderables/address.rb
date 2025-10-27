# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Address < Renderable
        attr_reader :recipient, :represented_by, :options

        def initialize(recipient, represented_by: nil, column: :left, height: 120, label: nil)
          super()
          @recipient = recipient.presence
          @represented_by = represented_by.presence
          @column = column
          @height = height || 120
          @label = label
        end

        def render # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
          bounding_box [x_position, y_position], width: 200, height: @height do
            text @label, style: :bold if @label
            next if @recipient.blank? && @represented_by.blank?

            if @recipient.present? && @represented_by.blank?
              render_address(@recipient)
            elsif @recipient.blank? && @represented_by.present?
              render_address(@represented_by)
            # elsif @recipient.is_a?(::Address) && @represented_by.is_a?(String)
            #   render_with_represented_by(@recipient, @represented_by)
            # elsif @recipient.is_a?(String) && @represented_by.is_a?(::Address)
            #   render_with_represented_by(@recipient, @represented_by)
            # elsif @recipient.is_a?(::Address) && @represented_by.is_a?(::Address)
            else
              render_with_represented_by(@recipient, @represented_by)
            end

            move_down 5
          end
        end

        private

        def render_with_represented_by(address, represented_by)
          render_address @recipient
          move_down 5
          text I18n.t('contracts.represented_by'), size: 7
          move_down 5
          render_address(@represented_by)
        end

        def render_address(address)
          return if address.blank?

          approximate_lines = address.to_s.lines&.flat_map { (it.length / 45) + 1 }&.sum
          text address.to_s, size: (13 - [approximate_lines, 4].compact.max).clamp(7, 9)
        end

        def x_position
          @column == :right ? 300 : 0
        end

        def y_position
          690
        end
      end
    end
  end
end
