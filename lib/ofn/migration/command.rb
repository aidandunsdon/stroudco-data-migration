module Ofn
  module Migration
    class Command

      def initialize
        @config = Config.get
        @io = Io.new
      end

      #def source_tables
      #  @config[:source_tables]
      #end
      #
      #def destination_tables
      #  @config[:destination_tables]
      #end
      #
      #def destination_entities
      #  @config[:destination_entities]
      #end


      def say_status(text, status, status_colors)
        @shell ||= Thor::Shell::Color.new
        @shell.say text, nil, false
        @shell.say @shell.set_color(status, *status_colors)
      end

      def say(text, colors=nil)
        @shell ||= Thor::Shell::Color.new
        @shell.say(text, *colors)
      end

      #def source_file(timestamp, basename)
      #  @config.source_file(timestamp, basename)
      #end
      #
      #def destination_file(timestamp, basename)
      #  @config.destination_file(timestamp, basename)
      #end
      #
      #def source_directory(timestamp)
      #  @config.source_directory(timestamp)
      #end
      #
      #def destination_directory(timestamp)
      #  @config.destination_directory(timestamp)
      #end
      #
      #def current_timestamp
      #  @config.current_timestamp
      #end
      #
      #def timestamp_regexp
      #  @config.timestamp_regexp
      #end
      #
      def last_dumps
        @dumps ||= ::Pathname.new(@config[:data_dir]).children.select do |e|
          e.directory? and @config[:timestamp_regexp] =~ e.basename.to_s
        end.map{|e| e.basename.to_s }.sort
      end

      def current_dump
        last_dumps[-1]
      end

      def previous_dump
        last_dumps[-2] if last_dumps
      end

    end
  end
end
