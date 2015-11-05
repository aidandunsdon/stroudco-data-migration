module Ofn
  module Migration
    module Source

      class Member < Ofn::Migration::Model
        has_attributes :member_id, :member_first_name, :member_last_name, :member_email, :member_address1, :member_address2, :member_address3, :member_town, :member_county, :member_postcode, :supplier_id
      end

      class Product < Ofn::Migration::Model
        has_attributes :product_id, :product_name,  :product_description, :product_category_id, :product_supplier_id, :product_code, :product_pkg_count, :product_available, :product_cost, :product_units, :product_more_info, :product_VAT_rate, :product_default_quantity_available
      end

      class Supplier < Ofn::Migration::Model
        has_attributes :supplier_id, :supplier_name, :supplier_info, :supplier_contact_name, :supplier_phone, :supplier_email, :supplier_address1, :supplier_address2, :supplier_address3, :supplier_town, :supplier_county, :supplier_postcode
      end
    end
  end
end