module Ofn
  module Migration
    class Config

      def self.get
        @@singleton ||= Config.new
      end

      def self.override(attrs)
        self.get.instance_variable_get(:@opts).merge!(attrs)
        self.get
      end

      def source_file(timestamp, basename)
        File.join(source_directory(timestamp), "#{basename}.yml")
      end

      def destination_file(timestamp, basename)
        File.join(destination_directory(timestamp), "#{basename}.yml")
      end

      def source_directory(timestamp)
        File.join(@opts[:data_dir], timestamp, "source")
      end

      def destination_directory(timestamp)
        File.join(@opts[:data_dir], timestamp, "destination")
      end

      def current_timestamp
        #the pattern must allow lexicographic sorting, to know which one is the most recent.
        "#{Time.now.strftime(@opts[:time_pattern])}"
      end

      def timestamp_regexp
        @opts[:timestamp_regexp]
      end

      def[](value)
        @opts[value]
      end

      protected

      attr_reader :opts

      def initialize
        @opts = {
            time_pattern: '%Y-%m-%d-%H-%M-%S',
            timestamp_regexp: /\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}/,
            data_dir: 'data',
            verbose: true,
            source_tables: {
                :product => Source::Product,
                :member => Source::Member,
                :supplier => Source::Supplier
            },
            destination_tables: {
                :spree_addresses => Destination::Spree::Address,
                :spree_products => Destination::Spree::Product,
                :spree_users => Destination::Spree::User,
                :spree_variants => Destination::Spree::Variant,
                :enterprises => Destination::Enterprise
            },
            # names of entities that will be written as separate files
            # addresses are not present, for example, because they're part of their parent entity.
            destination_entities: [:products, :enterprises, :users]
        }
      end

    end

  end
end