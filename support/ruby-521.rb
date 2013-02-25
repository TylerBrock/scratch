#!/usr/bin/env ruby
require 'benchmark'
require 'active_support/time'   # for Time.parse()
require 'bson'

h = {
  :_id=>"1-1651543736",
  :s_id=>23896626,
  :o_id=>1,
  :hash_code=>2074639573,
  :type=>0,
  :date_1=>Time.parse('2013-01-20 00:00:00 UTC'),
  :duration=>7,
  :s1=>2512.0,
  :s2=>2512.0,
  :cur=>2,
  :date_range=>[
    {:date=>{
        :from=>Time.parse('2013-01-20 00:00:00 UTC'),
        :to=>Time.parse('2013-01-27 00:00:00 UTC')
      }, 
    :hash_code=>-344124839
    }
  ],
  :extra_hashes=>
    ["1-0-ce3a1ae5bf8c6936b168f7f7ef13500f",
     "1-0-d2c44ee305712dc61a1740ac30ace545"],
  :del=>[],
  :state=>1,
  :created_at=>Time.now.utc
}
h_s = BSON.serialize h

Benchmark.bmbm do |x|
  x.report('serialization') { 1000000.times {a = BSON.serialize h} }
  x.report('deserialization')  { 1000000.times {a = BSON.deserialize h_s} }
end
