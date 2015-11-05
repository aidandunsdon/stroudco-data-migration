module Ofn
  module Migration
    #
    # Process a dump directory
    #
    # This class is used for the transformation step, mapping source fields into
    # destination fields and format conversions when needed.
    #
    #
    class Transform < Command

      def run
        process current_dump
      end

      def process(dir_name)

        hash = @io.read_from_source(dir_name)

        dest_hash = {}
        owners = {} # members/supplier relationships

        dest_hash[:users] = []
        hash[:member].each do |m|
          dest_hash[:users] << Destination::Spree::User.from_member(m)

          #store member_id of members by supplier
          if m[:supplier_id]
            owners[m[:supplier_id]] ||= []
            owners[m[:supplier_id]] << m[:member_id]
          end
        end

        dest_hash[:products] = []
        hash[:product].each do |p|
          dest_hash[:products] << Destination::Spree::Product.from(p)
        end

        dest_hash[:enterprises] = []
        hash[:supplier].each do |s|
          enterprise = Destination::Enterprise.from_supplier(s)

          #find member associated with this supplier (ownership)
          if owners[enterprise.source_id]
            enterprise.owner_source_id = owners[enterprise.source_id].first
          else
            puts "owners: #{owners}"
            raise "Couldn't find member/owner for supplier #{s[:supplier_id]}."
          end


          dest_hash[:enterprises] << enterprise
        end

        @io.write_to_destination(dir_name, dest_hash)

        say("Done.", [:white, :bold]) if @config[:verbose]

      end

      protected



      def print_counts(hash)
        hash.each do |k, v|
          say_status "#{k}: ", v.count, [:white, :bold]
        end
      end

    end
  end
end
