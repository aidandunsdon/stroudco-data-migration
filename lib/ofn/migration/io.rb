module Ofn
  module Migration
    class Io

      def initialize
        @config = Config.get
      end

      #for now we just read the whole thing into memory.
      #may be optimized in the future.
      def read_from_source(dir_name)
        hash = {}
        @config[:source_tables].each do |name, klass|
          hash[name] = YAML::load(File.read(@config.source_file(dir_name, name)))
        end
        hash
      end

      def write_to_destination(dir_name, hash)
        FileUtils.mkdir_p @config.destination_directory(dir_name)

        hash.each do |name, collection|
          File.write(@config.destination_file(dir_name, name), collection.to_yaml)
        end
      end

    end
  end
end