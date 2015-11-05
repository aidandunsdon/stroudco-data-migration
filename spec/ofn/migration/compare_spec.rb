require 'spec_helper'

module Ofn
  module Migration
    describe Compare do
      before do
        @config = Config.override({
            data_dir: '/tmp/ofn-tests',
            verbose: false
        })

        @io = Io.new

        #first dump
        @first = {
            products: [Destination::Spree::Product.from({product_id: 1, product_name: 'Product 1'})],
            enterprises: [],
            users: []
        }
        @io.write_to_destination('1', @first)

        #second dump
        @second = {
            products: [
                Destination::Spree::Product.from({product_id: 1, product_name: 'Product 1'}),
                Destination::Spree::Product.from({product_id: 2, product_name: 'Product 2'})
            ],
            enterprises: [],
            users: []
        }
        @io.write_to_destination('2', @second)
      end

      after do
        FileUtils.rm_r File.join('/tmp', 'ofn-tests')
      end

      it "runs" do
        result = Compare.new.run('1', '2')
        expect(result[:removed]).to be_empty
        expect(result[:updated]).to be_empty
        expect(result[:added][:users]).to be_nil
        expect(result[:added][:enterprises]).to be_nil
        expect(result[:added][:products]).to match_array([Destination::Spree::Product.from({product_id: 2, product_name: 'Product 2'})])

      end



    end
  end
end
