module Ofn
  module Migration

    class Model

      def self.has_attributes(*attrs)
        attr_accessor *attrs
        self.class_variable_set(:@@attributes, attrs)
      end

      def self.attributes
        class_variable_get(:@@attributes)
      end

      def ==(other)
        self.class.attributes.all? { |attr| send(attr) == other.send(attr) }
      end

    end

  end
end