# frozen_string_literal: true

require "sequel"

DB = Sequel.sqlite

DB.drop_table? :keyset
DB.create_table :keyset do
  primary_key :id
  integer :a, null: false
  integer :b, null: false
  text :name, null: false
end

data = [
  { id: 1,  a: 1, b: 1, name: "gerard" },
  { id: 2,  a: 1, b: 2, name: "angela" },
  { id: 3,  a: 1, b: 3, name: "dorien" },
  { id: 4,  a: 2, b: 1, name: "franky" },
  { id: 5,  a: 2, b: 2, name: "benzod" },
  { id: 6,  a: 3, b: 1, name: "johnny" },
  { id: 7,  a: 4, b: 1, name: "heaven" },
  { id: 8,  a: 4, b: 2, name: "easter" },
  { id: 9,  a: 4, b: 3, name: "ingrid" },
  { id: 10, a: 5, b: 1, name: "ceasar" }
]
DB[:keyset].multi_insert(data)

RSpec.configure do |config|
  config.filter_run_including focus: true
  config.run_all_when_everything_filtered = true
end
