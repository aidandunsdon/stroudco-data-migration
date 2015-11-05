require 'spec_helper'
require 'fileutils'

module Ofn
  module Migration
    describe Load do
      before do
        @config = Config.override({
          data_dir: '/tmp',
          verbose: false,
          sqlite: true
        })

        @db = Sequel.sqlite
        create_destination(@db)

        @dir_name = "#{Time.now.strftime(@config[:time_pattern])}"
        @dest_dir = File.join(@config[:data_dir], @dir_name, "destination")
        prepare_destination(@dest_dir)
      end

      after do
        #remove temporary files
        FileUtils.remove_entry_secure @dest_dir
      end

      it "runs" do
        Load.new(@db).run
      end

      def prepare_destination(dest_dir)
        FileUtils.mkdir_p dest_dir
        FileUtils.cp_r File.join(destination_fixture_path, '.'), dest_dir
      end
    end
  end
end
