module BookingStrategy
  module Base
    class Template
      def self.template_path(template)
        # binding.pry
        File.join('strategies', to_s.underscore, template)
      end
    end
  end
end
