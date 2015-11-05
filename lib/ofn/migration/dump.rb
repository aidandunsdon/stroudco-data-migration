module Ofn
  module Migration
    #
    # Dump given database to yaml files in the data directory.
    #
    class Dump < Command

      def initialize(db)
        super()
        @db = db
        @timestamp = @config.current_timestamp
      end

      def run

        FileUtils.mkdir_p @config.source_directory(@timestamp)

        @config[:source_tables].each do |name, klass|
          dump_table(name, klass)
        end

        say_status("Written to: ", "#{@timestamp}", [:white, :bold]) if @config[:verbose]
      end

      protected

      def dump_table(table_name, klass)
        File.write(@config.source_file(@timestamp, table_name), records(table_name, attributes(klass)).all.to_yaml)
      end

      def attributes(klass)
        klass.attributes
      end

      def records(table_name, fields)
        @db[table_name].select(*fields)
      end
    end
  end
end
