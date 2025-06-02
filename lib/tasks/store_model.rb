
module StoreModel
  module NestedAttributes
    module ClassMethods
      def define_association_setter_for_single(association, options)
        return unless options&.dig(:allow_destroy)

        define_method "#{association}=" do |attributes|
          if attributes.nil? || ActiveRecord::Type::Boolean.new.cast(attributes.stringify_keys["_destroy"])
            super(nil)
          else
            super(attributes)
          end
        end
      end
    end
  end
end
