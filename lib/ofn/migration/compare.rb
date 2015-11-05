module Ofn
  module Migration
    class Compare < Command

      def initialize
        super()
        @result = {
            added: {},
            updated: {},
            removed: {}
        }
      end

      def run(previous_dir, current_dir)

        say("Couldn't find dump file", :red) and raise if current_dir.nil?

        previous = {}

        @config[:destination_entities].each do |name|
          previous[name] = {}
          #load previous dump for this entity
          YAML::load(File.read(@config.destination_file(previous_dir, name))).each do |record|
            #hash key is record id.
            #here it's assumed that every record has an id
            #which happens for the destination schema
            previous[name][record.id] = record
          end

          #load current dump for this entity
          YAML::load(File.read(@config.destination_file(current_dir, name))).each do |record|

            #check if record exists in previous dump
            if previous[name].has_key? record.id

              unless record == previous[name][record.id]
                #updated record.
                @result[:updated][name] ||= []
                @result[:updated][name] << record
              end

              #delete from hash so at the end we'll which ones were removed.
              previous[name].delete record.id

            else
              @result[:added][name] ||= []
              @result[:added][name] << record
            end

            #check for deleted records.
            #we can just go over the 'previous' hash and any remaining means it was removed.

          end

        end

        @result
      end

    end
  end
end
