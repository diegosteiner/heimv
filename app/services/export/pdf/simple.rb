require 'prawn'

module Export
  module Pdf
    class Simple < Base
      to_render do 
        text "Hello, World"
      end
    end
  end
end
