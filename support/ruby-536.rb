#!/usr/bin/env ruby
require 'mongo'
include Mongo

def test_binary_2
  line = 'db.users.remove();db.users.insert({name: "Jim", someBinData: new BinData(2,"1234")});'
  File.open('/tmp/bindata.js', 'w'){|f| f.write(line)}
  system('mongo /tmp/bindata.js > /dev/null 2>&1')
  coll = Mongo::MongoClient.new('localhost', 27017)['test']['users']
  p coll.find.first['someBinData'].to_s
  puts "done"
end

test_binary_2
