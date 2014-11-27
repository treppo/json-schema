$: << '../lib'
require 'jschema'
require_relative '../lib/json-schema'
require 'json'
require 'stackprof'
require 'graphviz'
require 'benchmark'

json = JSON.parse "{\"offers\": [{\"id\":1,\"code\":\"C1DR4RZ9\",\"titles\":{\"en\":\"Nice apartment in Kreuzberg\"},\"object_types\":[\"apartment\"],\"public_coordinate\":{\"lat\":23.0,\"lng\":42.0},\"confidential_coordinate\":{\"lat\":23,\"lng\":45},\"geo_location_ids\":[1943],\"max_guest_count\":2,\"bedroom_count\":1,\"main_photo_id\":23523,\"is_external\":false,\"pricing\":{\"rate\":7000,\"from_price\":6000,\"cleaning_fee\":3000,\"included_guest_count\":1,\"extra_guest_cost\":1000,\"weekly_discount_rate\":5000},\"availabilities\":{\"default_min_nights\":1,\"max_nights\":9125},\"ranking\":{\"displays\":{\"search_displays_weighted\":0.0,\"guests_01_02_detail_displays\":0.0,\"guests_01_04_detail_displays\":0.0,\"guests_01_10_detail_displays\":0.0,\"guests_01_02_checkout_displays\":0.0,\"guests_01_04_checkout_displays\":0.0,\"guests_01_10_checkout_displays\":0.0},\"simple_scores\":{\"quality_score\":0,\"price_score\":0,\"farmer_score\":0.0}}}]}"
schema = JSON.parse File.read 'schema.json'

puts :json_schema, Benchmark.measure { 100.times { JSON::Validator.validate!(schema, json) } }
puts :jschema, Benchmark.measure { 100.times { JSchema.build(schema).validate(json) } }

json_schema = StackProf.run(mode: :object) do
  JSON::Validator.fully_validate(schema, json)
end

jschema = StackProf.run(mode: :object) do
  JSchema.build(schema).validate(json)
end

StackProf::Report.new(json_schema).print_graphviz(nil, File.new('prof-json-schema.dot',  'w+'))
StackProf::Report.new(jschema).print_graphviz(nil, File.new('prof-jschema.dot',  'w+'))

GraphViz.parse('prof-json-schema.dot').output(:png => 'prof-json-schema.png')
GraphViz.parse('prof-jschema.dot').output(:png => 'prof-jschema.png')
