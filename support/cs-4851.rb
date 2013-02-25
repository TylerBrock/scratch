#!/usr/bin/env ruby
require 'mongo'

conn = Mongo::Connection.new(:pool_size => 10)
db = conn['test']
coll = db['timeout']

coll.remove({}, :safe => true)

loop do
  begin
    Timeout::timeout(1) do
      loop do
        puts "."
        coll.insert({:a => BSON::ObjectId.new}, :safe => true)
      end
    end
  rescue Timeout::Error => ex
    #conn.close
    puts "rescued"
  end
end

puts 'done'
