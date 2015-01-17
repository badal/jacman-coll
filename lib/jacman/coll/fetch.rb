#!/usr/bin/env ruby
# encoding: utf-8
#
# File: globals.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  class Fetch
    TAB = "\t"

    # fetch a record in database
    # @param [String] database_name name of table in database
    # @param [String] name for error report
    # @param [#to_s] id identifier of record
    # @return [Hash] record as a Hash
    def self.item(database_name, name, id)
      query = "select * from #{database_name} where #{database_name}_id = \"#{id}\""
      item = Fetch.new(query).hashes.first
      fail ArgumentError, "#{name} with id #{id} does not exist in database" unless item
      item
    end

    # @param [String] qry SQl query
    # @return [Fetch] a new instance
    def initialize(qry)
      @fetch = Sql.answer_to_query(JACINTHE_MODE, qry)
    end

    # @return [Array<Array>] query answer : lines split by TAB
    def array
      @fetch.map { |line| line.chomp.split(TAB) }
    end

    # @return [Array<Hash>] query answer : array of hashes
    def hashes
      ary = array
      keys = ary.shift
      ary.map do |line|
        hsh = {}
        keys.zip(line).map do |key, value|
          value = value == 'NULL' ? nil : value
          hsh[key.to_sym] = value
        end
        hsh
      end
    end

    # FIXME: choose Array or Hash
    # @return [Array] query answer : array (indexed by id, value is rest of record)
    def table
      table = []
      array.drop(1).each do |line|
        id = line.shift.to_i
        table[id] = line
      end
      table
    end
  end
end
