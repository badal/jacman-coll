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
      Fetch.item('tiers', 'Tiers', tiers_id)
    end

    def self.fetch_client(client_id)
      Fetch.item('client_sage', 'Client', client_id)
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

p JacintheManagement::Coll.fetch_client('383')

__END__

table = JacintheManagement::Coll.full_ip_list
file = File.join(File.dirname(__FILE__), 'data', 'ip_table')
File.open(file, "w:utf-8") do |file|
  file.puts table.to_yaml
end
