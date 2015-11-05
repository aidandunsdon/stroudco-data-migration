require 'spec_helper'

module Ofn
  module Migration
    describe Dump do
      before do
        @config = Config.override({
          data_dir: '/tmp',
          verbose: false
        })

        @db = Sequel.sqlite
        create_source(@db)
      end

      after do
      end

      it "runs" do
        Dump.new(@db).run
      end
    end
  end
end
