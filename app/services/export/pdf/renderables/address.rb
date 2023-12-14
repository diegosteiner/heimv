# frozen_string_literal: true

module Export
  module Pdf
    module Renderables
      class Address < Renderable
        attr_reader :address, :options

        def initialize(address, options = {})
          super()
          @address = address.join("\n") if address.is_a?(Array)
          @address ||= address
          @address ||= ''
          @options = options
        end

        def representing?
          @options[:representing].present?
        end

        def render
          bounding_box [x_position, y_position], width: 200, height: @options[:height] || 120 do
            text @options[:label], size: 10, style: :bold if @options[:label]
            move_down 5

            if representing?
              text @options[:representing]
              move_down 5
              text I18n.t('contracts.represented_by'), size: 7
            end

            text @address
          end
        end

        private

        def x_position
          @options[:issuer] ? 0 : 300
        end

        def y_position
          690
        end
      end
    end
  end
end
