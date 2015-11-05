$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'ofn'

def source_fixture_path
  File.expand_path(File.join('..', 'fixtures', 'source'), __FILE__)
end

def destination_fixture_path
  File.expand_path(File.join('..', 'fixtures', 'destination'), __FILE__)
end

#prepare the source database schema
def create_source(db)
  db.create_table :product do
    primary_key :product_id
    Ofn::Migration::Source::Product.attributes.select { |a| ![:product_id].include?(a) }.each do |a|
      String a
    end
  end

  db.create_table :member do
    primary_key :member_id
    Ofn::Migration::Source::Member.attributes.select { |a| ![:member_id].include?(a) }.each do |a|
      String a
    end
  end

  db.create_table :supplier do
    primary_key :supplier_id
    Ofn::Migration::Source::Supplier.attributes.select { |a| ![:supplier_id].include?(a) }.each do |a|
      String a
    end
  end
end

def create_destination(db)
  db.create_table :spree_products do
    primary_key :id
    Ofn::Migration::Destination::Spree::Product.attributes.select { |a| ![:id].include?(a) }.each do |a|
      String a
    end
    Timestamp :created_at
    Timestamp :updated_at
  end

  db.create_table :spree_users do
    primary_key :id
    Ofn::Migration::Destination::Spree::User.attributes.select { |a| ![:id].include?(a) }.each do |a|
      String a
    end
    Timestamp :created_at
    Timestamp :updated_at
  end

  db.create_table :enterprises do
    primary_key :id
    Ofn::Migration::Destination::Enterprise.attributes.select { |a| ![:id].include?(a) }.each do |a|
      String a
    end
    Timestamp :created_at
    Timestamp :updated_at
  end

  db.create_table :spree_addresses do
    primary_key :id
    Ofn::Migration::Destination::Spree::Address.attributes.select { |a| ![:id].include?(a) }.each do |a|
      String a
    end
    Timestamp :created_at
    Timestamp :updated_at
  end

  db.create_table :spree_countries do
    primary_key :id
    String :name
    String :iso
  end

  db[:spree_countries].insert(id: 1, iso: 'GB')

  db.create_table :spree_taxons do
    primary_key :id
  end

  db[:spree_taxons].insert(id: 1)

  db.create_table :spree_tax_categories do
    primary_key :id
    String :name
  end

  db.create_table :spree_tax_rates do
    primary_key :id
    String :zone_id
    String :tax_category_id
  end



end

def test_spree_product(attrs)

end