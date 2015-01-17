#!/usr/bin/env ruby
# encoding: utf-8

# File: ams.rb
# Created: 30/12/2014
#
# (c) Michel Demazure <michel@demazure.com> begin

AMS = JacintheManagement::Coll::CollectiveSubscription.new('15')
AMS_tiers = JacintheManagement::Coll::Tiers.new(15)

p AMS.name

puts AMS_tiers.ranges

def table_extracted_from(ranges)
  table = {}
  key = nil
  ranges.each do |line|
    if line[0] == '#'
      mtch = /id(\d+)/.match(line)
      key = mtch ? mtch[1].to_i : line
      table[key] = []
    else
      table[key] << line
    end
  end
  table
end

table = table_extracted_from(AMS_tiers.ranges)

table.each_pair do |key, list|
  print "#{key} : "
  if key.is_a?(Integer)
    tiers = JacintheManagement::Coll::Tiers.new(key)
    puts tiers.compare_ranges(list)
  else
    puts 'no tiers'
  end
end
