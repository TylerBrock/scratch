#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'

@@options = {
  :pool_size        => 20,
  :read             => :secondary,
  :refresh_mode     => :sync,
  :refresh_interval => 5,
  :pool_timeout     => 500
}

@@client = Mongo::ReplSetConnection.new([
  'localhost:3000',
  'localhost:3001',
  'localhost:3002'], @@options)

coll = @@client['poshmark']['thread_tests']
coll.drop
coll.insert({:a => 1})

threads = []
1000.times do
  threads << Thread.new do
    coll = @@client['poshmark']['thread_tests']
    coll.find({'$where' => 'function() {for(i=0;i<100000;i++) {this.value};}'}).each {|e| e}
  end
end
threads.each { |t| t.join }
