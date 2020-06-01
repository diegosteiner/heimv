module Export
  module Pdf
    module Renderables
      class Address < Renderable
        attr_reader :address, :options

        def initialize(address, options = {})
          @address = address.join("\n") if address.is_a?(Array)
          @address ||= address
          @options = options
        end

        def render
          bounding_box [x_position, y_position], width: 200, height: 140 do
            default_leading 3
            text @options[:label], size: 13, style: :bold if @options[:label]
            move_down 5
            text @options[:representing] if @options[:representing].present?
            text 'vertreten durch:', size: 8 if @options[:representing].present?
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
