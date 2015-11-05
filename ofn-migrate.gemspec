require "#{File.dirname(__FILE__)}/lib/ofn/migration/version"

Gem::Specification.new do |s|
  s.name = "ofn-migrate"
  s.version = Ofn::Migration::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Stroudco"]
  s.email = ["aidan.dunsdon@live.co.uk"]
  s.homepage = "https://import.github.com/Stroudco/data-migration"
  s.summary = "Stroudco to OFN Data Migration"
  s.description = "..."
  #s.license = %q|MIT|

  s.files = `git ls-files`.split("\n") rescue ''
  s.require_path = ['lib']
  s.executables = ["ofn-migrate"]

  s.required_ruby_version = ">= 1.9.3"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "sequel"
  s.add_runtime_dependency "mysql2"
  s.add_runtime_dependency "pg"
  s.add_runtime_dependency "sqlite3"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "faker"
  s.add_development_dependency "pry"
end

