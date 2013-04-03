#!/usr/bin/env ruby
require 'mongo'
require 'base64'
include Mongo

def test_binary
  data = Base64.encode64([5].pack("l<") + "tyler").chop
  lines = [
    "db.users.drop();",
    "db.users.insert({data: new BinData(2,'#{data}')});"
  ]
  File.open('/tmp/bindata.js', 'w'){|f| f.puts(lines)}
  system('mongo /tmp/bindata.js > /dev/null 2>&1')
  coll = Mongo::MongoClient.new('localhost', 27017)['test']['users']
  p coll.find.first['data'].to_s
end

test_binary
