require 'spec_helper'
require 'fileutils'

module Ofn
  module Migration
    describe Transform do
      before do
        @config = Config.override({
            data_dir: '/tmp',
            verbose: false
        })

        @dir_name = @config.current_timestamp
        @source_dir = @config.source_directory(@dir_name)
        prepare_source(@source_dir)
      end

      after do
        FileUtils.remove_entry_secure @source_dir
      end

      it "runs" do
        Transform.new.process(@dir_name)
      end

      def prepare_source(dest_dir)
        FileUtils.mkdir_p dest_dir
        FileUtils.cp_r File.join(source_fixture_path, '.'), dest_dir
      end
    end
  end
end
