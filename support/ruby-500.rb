#!/usr/bin/env ruby
require 'mongo'

@conn = Mongo::Connection.new('localhost', 27017)
@db = @conn['db']
@collection = @db['test_collection']

code = -> { @collection.find({"Name" => "aaron.symplicity.com"}).each {|d| d} }
#code = -> { "test" }
high = 0
pid = 0
size = 0

loop do
  th = Thread.new do
    code.call
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{Process::pid}"`.chomp.split(/\s+/).map {|s| s.strip.to_i}
    if size > high
      puts "New high: #{size}"
      high = size
      p "Threads: #{ObjectSpace.each_object(Thread) {}}"
      p "Strings: #{ObjectSpace.each_object(String) {}}"
    end
  end
  th.join
end
