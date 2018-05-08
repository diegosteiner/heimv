module BookingStrategy
  module Base
    class ViewHelper
      def self.template_path
        File.join(__dir__, 'views')
      end

      def self.view
        ActionView::Base.new([template_path], {})
      end
    end
  end
end
