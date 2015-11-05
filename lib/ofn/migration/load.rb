module Ofn
  module Migration
    #
    # Load a directory of yaml files to the database.
    #
    #
    class Load < Command

      def initialize(db)
        super()
        @db = db
      end

      def run

        result = {}

        if previous_dump.nil?
          result[:added] = {}

          @config[:destination_entities].each do |name|
            result[:added][name] = YAML::load(File.read(@config.destination_file(current_dump, name)))
          end

        else
          result = Compare.new.run(previous_dump, current_dump)
          if @config[:verbose]
            puts "====="
            puts "added: #{result[:added].count}"
            puts "updated: #{result[:updated].count}"
            puts "removed: #{result[:removed].count}"
          end
        end

        process_added(result[:added])
        process_updated(result[:updated])
        process_removed(result[:removed])

        say("Done.", [:white, :bold]) if @config[:verbose]
      end

      def process_removed(hash)
        #TODO
      end

      def process_updated(hash)
        #TODO
      end

      def process_added(hash)
        user_id_mapping = {} #mapping from source id to new id
        enterprise_id_mapping = {} # mapping from supplier id to enterprise id

        hash[:users].each do |u|
          insert_user(u)
          user_id_mapping[u.source_id] = u.id
        end  if hash.has_key? :users

        hash[:enterprises].each do |e|
          e.owner_id = user_id_mapping[e.owner_source_id]
          insert_enterprise(e)
          enterprise_id_mapping[e.source_id] = e.id
        end if hash.has_key? :enterprises

        hash[:products].each do |p|
          p.supplier_id = enterprise_id_mapping[p.supplier_source_id]
          insert_product(p)
        end  if hash.has_key? :products
      end

      def insert_product(p)
        #puts "insert product #{p.id}"
        insert_model(:spree_products, p, {tax_category_id: tax_categories[p.tax_category_name][:id]})
        p.variants.each do |variant|
          variant.id = insert_returning_id(:spree_variants, raw_model_values(variant).merge({product_id: p.id}))
          variant.prices.each do |price|
            price.id = insert_returning_id(:spree_prices, raw_model_values(price).merge(variant_id: variant.id))
          end
        end
      end

      def insert_user(u)
        insert_address(u.address)

        #puts "inserting user #{u.id}"
        insert_model(:spree_users, u, {bill_address_id: u.address.id, ship_address_id: u.address.id})
      end

      def insert_enterprise(e)
        insert_address(e.address)

        #puts "inserting enterprise #{e.id}"
        insert_model(:enterprises, e, {address_id: e.address.id})
      end

      def insert_address(a)
        a.country_id = uk[:id] #every address will be UK by default
        insert_model(:spree_addresses, a)
      end

      def insert_returning_id(table_name, attributes)
        with_table = @db[table_name]

        #the method to obtain last inserted id is adapter-dependent
        unless @config[:sqlite]
          with_table = with_table.returning
        end

        updated_hash = with_table.insert(attributes)

        if @config[:sqlite]
          id = @db.run("select last_insert_rowid()") #only if testing with sqlite
        else
          id = updated_hash.first[:id]
        end

        id
      end

      def insert_model(table_name, model, overrides={})
        model.id = insert_returning_id(table_name, model_values(model).merge(overrides).merge({created_at: Time.now, updated_at: Time.now}))
        model
      end

      def model_values(model)
        values = {}
        prohibited = [:id, :created_at, :updated_at, :source_id, :owner_source_id, :supplier_source_id]
        table_name = @config[:destination_tables].invert[model.class] || raise("Unknown model: #{model.class}")
        @db[table_name].columns.each do |column|
          v = model.send("#{column}") if !prohibited.include?(column) and model.respond_to?(column)
          values[column] = v if v
        end
        values
      end

      #models not in destination tables -- variant, prices, etc.
      def raw_model_values(model)
        values = {}
        prohibited = [:id, :created_at, :updated_at]
        model.class.attributes.each do |attr|
          v = model.send("#{attr}") unless prohibited.include?(attr)
          values[attr] = v if v
        end
        values
      end

      #tax categories. they will be created if currently not in the database
      def tax_categories
        @categories ||= {
            'Exempt Rate' => {
                :id => nil,
                :rate => 0.00
            },
            'Low Rate' => {
                :id => nil,
                :rate => 0.05
            },
            'Full Rate' => {
                :id => nil,
                :rate => 0.20
            }
        }

        @categories.reject{|k,v| v[:id] }.each do |category_name, value|

          current = @db[:spree_tax_categories].where(:name => category_name).first

          if current
            value[:id] = current[:id]

          else
            timestamps = {:created_at => Time.now, :updated_at => Time.now}

            value[:id] = insert_returning_id(:spree_tax_categories, timestamps.merge({
              :name => category_name
            }))

            insert_returning_id(:spree_tax_rates, timestamps.merge({
              :amount => value[:rate],
              :zone_id => eu_zone[:id],
              :tax_category_id => value[:id]
            }))
          end

        end

        @categories
      end

      def eu_zone
        @zone ||= @db[:spree_zones].where(name: 'EU_VAT').first or raise 'EU_VAT zone is not present in table spree_zones'
      end

      def uk
        # we just assume UK is present in the destination database because it's in spree's seeds.
        # { name: "United Kingdom", iso3: "GBR", iso: "GB", iso_name: "UNITED KINGDOM", numcode: "826" }
        @uk ||= @db[:spree_countries].where(iso: 'GB').first or raise 'UK is not present in table spree_countries'
      end

    end
  end
end
