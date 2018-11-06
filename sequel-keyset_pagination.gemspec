# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = "sequel-keyset_pagination"
  s.version       = "0.0.1"
  s.date          = "2018-11-06"
  s.summary       = "Keyset Pagination Extension for Sequel"
  s.description   = "Adds support to Sequel for easy cursor based pagination on datasets"
  s.authors       = ["Sarah Henkens"]
  s.email         = ["sarah.a.henkens@gmail.com"]
  s.files         = ["lib/sequel/extensions/keyset_pagination.rb"]
  s.homepage      = "https://github.com/sarahhenkens/sequel-keyset_pagination"
  s.license       = "MIT"

  s.add_runtime_dependency "sequel", "~> 5.0"
  s.add_development_dependency "rspec", "~> 3.8"
  s.add_development_dependency "sqlite3"
end
