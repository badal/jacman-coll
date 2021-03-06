#!/usr/bin/env ruby
# encoding: utf-8
#
# File: fetch.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  # wrapping class for SQL queries
  class Fetch
    TAB = "\t"

    # fetch a record in database
    # @param [String] table_name name of table in database
    # @param [#to_s] id identifier of record
    # @return [Hash|nil] record as a Hash, nil if not existing
    def self.item(table_name, id)
      query = "select * from #{table_name} where #{table_name}_id = #{id}"
      Fetch.new(query).hashes.first
    end

    attr_reader :fetch

    # @param [String] file_name sql file where the query script is
    # @return [Fetch] new instance with this query
    def self.from_script(file_name)
      query = SQLFiles.script(file_name)
      new(query)
    end

    # @param [String] qry SQl query
    # @return [Fetch] a new instance
    def initialize(qry)
      @fetch = Sql.answer_to_query(JACINTHE_MODE, qry, '2>&1')
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
