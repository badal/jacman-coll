#!/usr/bin/env ruby
# encoding: utf-8
#
# File: globals.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  # methods for management of collective subscriptions
  module Coll
    YEAR = Time.now.year

    # @param [#to_s] tiers_id identifier of tiers
    # @return [Hash|nil] record as a Hash, nil if not existing
    def self.fetch_tiers(tiers_id)
      Fetch.item('tiers', tiers_id)
    end

    # @param [#to_s] client_id identifier of client_sage
    # @return [Hash|nil] record as a Hash, nil if not existing
    def self.fetch_client(client_id)
      Fetch.item('client_sage', client_id)
    end

    # @param [#to_s] tiers_id identifier of tiers
    # @return [String] field :tiers_nom
    def self.fetch_tiers_name(tiers_id)
      fetch_tiers(tiers_id)[:tiers_nom]
    end

    # @param [#to_s] tiers_id identifier of tiers
    # @return [Array<Hash>] all client with this tiers as client_final
    def self.fetch_client_for_tiers(tiers_id)
      qry = "select * from client_sage where client_sage_client_final=#{tiers_id}"
      Fetch.new(qry).hashes
    end

    # @return [String] MySql insertion query
    # @param [String] table where record has to be inserted
    # @param [Hash] parameters  column => value
    def self.insert_in_base(table, parameters)
      qry = "INSERT IGNORE INTO #{table} (#{parameters.keys.join(', ')})\
 VALUES (#{parameters.values.join(', ')})"
      answer = Fetch.new(qry).fetch
      fail(SQLError, "Invalid insert query #{qry}") unless answer.empty?
    end

    # @param [String] table where record has to be inserted
    # @param [Hash] parameters  column => value
    def self.selection_query(table, parameters)
      qry = "SELECT #{table}_id FROM #{table} WHERE "
      criteria = parameters.each_pair.map do |key, value|
        "#{key}=#{value}"
      end.join(' AND ')
      qry + criteria
    end

    # @param [String] table where record has to be searched
    # @param [Hash] parameters  column => value
    # @return [Object] identifier or nil
    def self.find(table, parameters)
      qry = Coll.selection_query(table, parameters)
      ans = Fetch.new(qry).array.last
      ans ? ans.first.to_i : ans
    end

    # @param [String] table where record has to be inserted
    # @param [Hash] parameters  column => value
    # @return [Object] identifier
    def self.insert_if_needed(table, parameters)
      return nil if find(table, parameters)
      Coll.insert_in_base(table, parameters)
      find(table, parameters)
    end

    # @return [Array] indexed by journal_id, values are couples [acronym, name]
    def self.journals
      @journals ||= fetch_journals
    end

    # @return [Array] all journal ids
    def self.journal_ids
      @journals.keys
    end

    # @return [Hash] id => [code, name]
    def self.fetch_journals
      Fetch.new('select * from revue;').table
    end

    # source file for the query
    SQL_FILE = 'find_electronic_subscriptions'

    # @return [Array<Hash>] all electronic e_subs as hashes
    def self.all_esubs
      @all_esubs ||= Fetch.from_script(SQL_FILE).hashes
    end
  end
end

__END__

    # convert values to IpRange ?
    # to cache ?
    # @return [Array<Array>] indexed by tiers_id, values are arrays of IPs
    def self.full_ip_list
      query = 'select tiers_id, tiers_ip_plage from tiers where tiers_ip_plage is not null'
      Fetch.new(query).table.map do |range|
        range ? range.first.chomp.split('\\n') : []
      end
    end

table = JacintheManagement::Coll.full_ip_list
file = File.join(File.dirname(__FILE__), 'data', 'ip_table')
File.open(file, "w:utf-8") do |file|
  file.puts table.to_yaml
end
