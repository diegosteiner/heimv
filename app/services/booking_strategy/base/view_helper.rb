module BookingStrategy
  module Base
    class ViewHelper
      self << class
        def template_path
          File.join(__dir__, 'views')
        end

        def view
          ActionView::Base.new([template_path], {})
        end
      end
    end
  end
end
