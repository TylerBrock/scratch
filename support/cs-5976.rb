require 'rubygems'
require 'mongo'

module FakeClient
  module Test

    POOL_SIZE=5
    connection = Mongo::MongoReplicaSetClient.new(
      ['localhost:3000', 'localhost:3001', 'localhost:3002'],
      {:w => 1, :read => :primary, :pool_size => POOL_SIZE, :connect_timeout => 5}
    )
    @db = connection['gp_bm']
    COLLECTION = 'embedded_docs'

    def run_concurrent_threads

      puts "Pool size: #{POOL_SIZE}"
      # Delete and insert embedded docs
      @db[COLLECTION].remove
      puts "inserting 500 sample embedded docs"
      insert_embedded_docs

      threads = []
      5.times do |i|
        threads << Thread.new(i) do |i|
          Thread.current[:name] = i
          run_query
        end
      end
      sleep(5)
      threads << Thread.new do
        Thread.current[:name] = "A"
        run_interleaved_queries
      end
      sleep(1)
      threads << Thread.new do
        Thread.current[:name] = "B"
        run_slow_query
      end
      threads.each(&:join)
    end

    private

    def insert_embedded_docs
      500.times do |i|
        embeds = []
        100.times do |j|
          embeds << {:_id => j, :n => "embed-#{j}", :v => j}
        end
        @db[COLLECTION].insert({
                                   :_id => i,
                                   :name => "embedded-#{i}",
                                   :uat => Time.now,
                                   :tp => :embedded,
                                   :ct => i,
                                   :refs => embeds
                               })
      end
    end

    def run_interleaved_queries
      @db[COLLECTION].find(:name => {'$in' => Array.new(20) { |e| "embedded-#{1 + e}" }}).each { |embedded|
        embedded
      }
      puts "#{Thread.current[:name]}: going to sleep after executing one query"
      Thread.pass
      sleep(10)
      puts "#{Thread.current[:name]}: woke up and attempting to execute second query"
      @db[COLLECTION].find(:name => {'$in' => Array.new(20) { |e| "embedded-#{100 + e}" }}).each { |embedded|
        embedded
      }
      puts "#{Thread.current[:name]}: finished executing second query"
    end

    def run_slow_query
      puts "#{Thread.current[:name]}: executing slow query"
      st = Time.now
      @db[COLLECTION].find({'$where' => "function() {for(i=0;i<500000;i++) {this.name};}"}).each do |embedded|
        embedded
      end
      puts "#{Thread.current[:name]}: after executing slow query: #{Time.now - st} seconds"
    end

    def run_query
      puts "#{Thread.current[:name]}: executing query"
      @db[COLLECTION].find(:name => {'$in' => Array.new(20) { |e| "embedded-#{1 + e}" }}).each { |embedded|
        embedded
      }
      puts "#{Thread.current[:name]}: done executing query"
    end

  end
end

include FakeClient::Test
FakeClient::Test::run_concurrent_threads
