module BookingStrategy
  class Base
    def self.template_path(template)
      File.join('strategies', to_s.underscore, template)
    end
  end
end
