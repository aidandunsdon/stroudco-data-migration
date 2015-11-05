require 'pry'

module Ofn
  module Migration

    class Application < Thor

      desc "dump", "Dump data from the source database to file"
      def dump
        url = ENV['SOURCE_DATABASE_URL'] or raise 'Please provide SOURCE_DATABASE_URL'
        db = Sequel.connect(url, :logger => Logger.new(File.join('log', 'source.log')))
        Dump.new(db).run
      end

      desc "process", "Process last dumped to prepare for the load"
      def process
        #Sequel.sqlite #in-memory database so sequel models do not complain.
        Transform.new.run
      end

      desc "load ", "Load data from the latest dump to the destination database"
      def load
        url = ENV['DESTINATION_DATABASE_URL'] or raise 'Please provide DESTINATION_DATABASE_URL'
        db = Sequel.connect(url, :logger => Logger.new(File.join('log', 'destination.log')))
        Load.new(db).run
      end

    end

  end
end
