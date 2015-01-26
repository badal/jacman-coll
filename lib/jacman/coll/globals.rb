#!/usr/bin/env ruby
# encoding: utf-8
#
# File: globals.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Coll
    YEAR = Time.now.year

    def self.fetch_tiers(tiers_id)
      Fetch.item('tiers', tiers_id)
    end

    def self.fetch_client(client_id)
      Fetch.item('client_sage', client_id)
    end

    def self.fetch_client_for_tiers(tiers_id)
      qry = "select * from client_sage where client_sage_client_final=#{tiers_id}"
      Fetch.new(qry).hashes
    end

    # @return [String] MySql insertion query
    # @param [String] table where record has to be inserted
    # @param [Hash] hsh  column => value
    def self.insert_in_base(table, hsh)
      qry = "INSERT IGNORE INTO #{table} (#{hsh.keys.join(', ')})\
 VALUES (#{hsh.values.join(', ')})"
      answer = Fetch.new(qry).fetch
      fail "Invalid insert query #{qry}" unless answer.empty?
    end

    # @param [String] table where record has to be inserted
    # @param [Hash] hsh  column => value
    def self.selection_query(table, hsh)
      qry = "SELECT #{table}_id FROM #{table} WHERE "
      criteria = hsh.each_pair.map do |key, value|
        "#{key}=#{value}"
      end.join(' AND ')
      qry + criteria
    end

    # @param [String] table where record has to be searched
    # @param [Hash] hsh  column => value
    # @return [Object] identifier or nil
    def self.find(table, hsh)
      qry = Coll.selection_query(table, hsh)
      ans = Fetch.new(qry).array.last
      ans ? ans.first.to_i : ans
    end

    # @param [String] table where record has to be inserted
    # @param [Hash] hsh  column => value
    # @return [Object] identifier
    def self.insert_if_needed(table, hsh)
      number = find(table, hsh)
      return number if number
      Coll.insert_in_base(table, hsh)
      find(table, hsh)
    end




    # @return [Array] indexed by journal_id, values are couples [acronym, name]
    def self.journals
      @journals ||= fetch_journals
    end

    # @return [Array] all journal ids
    def self.journal_ids
      @journals.keys
    end

    # FIXME: could be array
    # @return [Hash] id => [code, name]
    def self.fetch_journals
      Fetch.new('select * from revue;').table
    end

    # FIXME: convert values to IpRange ?
    # FIXME: to cache
    # @return [Array<Array>] indexed by tiers_id, values are arrays of IPs
    def self.full_ip_list
      query = 'select tiers_id, tiers_ip_plage from tiers where tiers_ip_plage is not null'
      Fetch.new(query).table.map do |range|
        range ? range.first.chomp.split('\\n') : []
      end
    end
  end
end

p JacintheManagement::Coll.journals

p JacintheManagement::Coll.fetch_client_for_tiers(5)
p JacintheManagement::Coll.fetch_client(5)
p JacintheManagement::Coll.fetch_client("383")


__END__

table = JacintheManagement::Coll.full_ip_list
file = File.join(File.dirname(__FILE__), 'data', 'ip_table')
File.open(file, "w:utf-8") do |file|
  file.puts table.to_yaml
end
