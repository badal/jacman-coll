#!/usr/bin/env ruby
# encoding: utf-8

# File: cnrs.rb
# Created: 26/12/2014
#
# (c) Michel Demazure <michel@demazure.com>

# TODO: build a new client : '1610EBSCO'
CNRS = JacintheManagement::Coll::Provider.new('1610')

RNBM = JacintheManagement::Coll::CollectiveSubscription.new('RNBM', CNRS)

RNBM.journal_ids = [1, 2, 6, 17]

p RNBM

CNRS_tiers = JacintheManagement::Coll::Tiers.new(1610)

ranges = CNRS_tiers.ranges

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

