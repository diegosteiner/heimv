# frozen_string_literal: true

module Import
  module Hash
    class Base
      attr_reader :options

      delegate :used_attributes, :actors, to: :class

      Mount = Struct.new(:mountpoint, :klass, :as, :options) do
        def instance
          klass.new(**(options || {}))
        end
      end

      def initialize(**options)
        default_options = {}
        @options = default_options.deep_merge(options)
      end

      def initialize_record(_hash)
        raise NotImplementedError
      end

      def import(hash, record = nil)
        record ||= initialize_record(hash)
        record.assign_attributes(hash.slice(*used_attributes))
        actors.each do |actor_block|
          instance_exec(record, hash, &actor_block)
        end
        record
      end

      def self.used_attributes
        @used_attributes ||= []
      end

      def self.use_attributes(*args)
        used_attributes.concat(args).flatten!
      end

      def self.actor(&block)
        actors << block
      end

      def self.actors
        @actors ||= []
      end
    end
  end
end
