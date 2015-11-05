module Ofn
  module Migration
    module Destination

      class Enterprise < Ofn::Migration::Model
        has_attributes :id, :name, :description, :long_description, :contact, :phone, :email, :address_id, :owner_id, :visible, :sells, :permalink, :confirmed_at, :is_primary_producer
        attr_accessor :address
        attr_accessor :source_id
        attr_accessor :owner_source_id

        def self.from_supplier(s)
          e = Enterprise.new
          e.id = s[:supplier_id]
          e.name = s[:supplier_name]
          e.long_description = s[:supplier_info]
          e.contact = s[:supplier_contact_name]
          e.visible = true
          e.sells = 'own'
          e.permalink = "Enterprise_#{s[:supplier_id]}"
          e.confirmed_at = Time.now
          e.is_primary_producer = true

          a = Spree::Address.new
          a.firstname = s[:supplier_name]
          a.lastname = s[:supplier_contact_name]
          a.address1 = s[:supplier_address1]
          a.address2 = s[:supplier_address2]
          #a.address3 = s[:supplier_address3]
          a.zipcode = s[:supplier_postcode]
          a.city = s[:supplier_town]
          a.state_name = s[:supplier_county]
          #a.country_id = 44 -- no need to hardcode country here, it's already hardcoded during Load
          e.address = a
          e.source_id = s[:supplier_id]
          e
        end

      end

      module Spree
        class Product < Ofn::Migration::Model
          has_attributes :id, :name, :description, :available_on, :on_demand, :notes, :supplier_id, :variant_unit, :primary_taxon_id, :count_on_hand, :permalink
          attr_accessor :variants
          attr_accessor :source_id
          attr_accessor :supplier_source_id
          attr_accessor :tax_category_name

          def self.from(p)
            sp = Spree::Product.new
            sp.id = p[:product_id]
            sp.name = p[:product_name]
            sp.description = p[:product_description]
            sp.supplier_source_id = p[:product_supplier_id]
            sp.variant_unit = p[:variant_unit]
            sp.notes = p[:notes]
            sp.available_on = Time.now if p[:product_available]
            sp.on_demand = false
            sp.count_on_hand = p[:product_default_quantity_available]
            sp.permalink = "Product_DF_#{sp.id}"




            sp.tax_category_name = case p[:product_VAT_rate]
              when (0.2)...1
               'Full Rate'
              when (0.05)...(0.2)
               'Low Rate'
              else
               'Exempt Rate'
              end

            sp.primary_taxon_id = {
                3  => 2,
                11 => 4,
                16 => 5,
                14 => 6,
                13 => 7,
                10 => 8,
                17 => 9,
                7  => 10,
                8  => 11,
                2  => 12,
                18 => 13,
                9  => 14
            }.fetch(p[:product_category_id], 1)

            #variant
            v = Spree::Variant.new
            v.sku = p[:product_code]
            v.count_on_hand = sp.count_on_hand
            v.cost_price = 0
            v.is_master = true

            price = Spree::Price.new
            price.amount = p[:product_cost]
            price.currency = 'GBP'
            v.prices = [price]

            sp.variants = [v]

            sp.source_id = p[:product_id]
            sp
          end
        end

        class User < Ofn::Migration::Model
          has_attributes :id, :email, :login, :address_id, :bill_address_id, :ship_address_id, :api_key
          attr_accessor :address
          attr_accessor :source_id

          def self.from_member(m)
            u = Spree::User.new
            u.id = m[:member_id]
            u.email = m[:member_email]
            u.login = m[:member_email]
            #u.api_key = m[:member_id]

            a = Spree::Address.new
            a.firstname = m[:member_first_name]
            a.lastname = m[:member_last_name]
            a.address1 = m[:member_address1]
            a.address2 = m[:member_address2]
            #a.address_3 = m[:member_address3]
            a.zipcode = m[:member_postcode]
            a.city = m[:member_town]
            a.state_name = m[:member_county]
            #a.country_id = 44 -- no need to hardcode country here, it's already hardcoded during Load

            u.address = a
            u.source_id = m[:member_id]
            #u.api_key = m[:member_id]

            u
          end


        end

        class Address < Ofn::Migration::Model
          has_attributes :id, :firstname, :lastname, :address1, :address2, :city, :state_name, :zipcode, :country_id
        end

        class Variant < Ofn::Migration::Model
          has_attributes :id, :sku, :count_on_hand, :cost_price, :product_id, :is_master
          attr_accessor :prices
        end

        class Price < Ofn::Migration::Model
          has_attributes :id, :variant_id, :amount, :currency
        end

        class TaxCategory < Ofn::Migration::Model
          has_attributes :id, :name, :description
          attr_accessor :rates
        end

        class TaxRate < Ofn::Migration::Model
          has_attributes :id, :amount, :zone_id, :tax_category_id, :name
        end

      end
    end
  end
end
