#!/usr/bin/env ruby
#require 'mongo'

conn = Mongo::ReplSetClient.new(
  ["localhost:3000","localhost:3001","localhost:3002"],
  :pool_size => 5,
  :pool_timeout => 5,
  :op_timeout => 10,
  :connect => true,
  :refresh_mode => :sync
)

threads = []

10.times do
  threads << Thread.new do
    1000.times do |i|
      if i % 3 == 0
        conn.refresh
      elsif i % 3 == 1
        conn['test']['test'].insert({:a => 1})
      else
        conn['test']['test'].find
      end
    end
  end
end

threads.each {|t| t.join}
