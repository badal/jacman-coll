#!/usr/bin/env ruby
# encoding: utf-8
#
# File: tiers.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Coll
    class Tiers
      attr_reader :ranges

      def initialize(tiers_id)
        @tiers = Coll.fetch_tiers(tiers_id)
        range = @tiers[:tiers_ip_plage]
        @ranges = range ? range.chomp.split('\\n') : []
      end

      def compare_ranges(given_ranges)
        range_set = @ranges.to_set
        given_set = given_ranges.to_set
        if range_set == given_set
          :EQUAL
        elsif range_set.superset?(given_set)
          :MORE
        elsif range_set.subset?(given_set)
          :LESS
        else
          :DIFFERENT
        end
      end
    end
  end
end

begin
  JacintheManagement::Coll::Tiers.new(-1)
rescue => err
  p err
end

p JacintheManagement::Coll::Tiers.new(15).ranges

p JacintheManagement::Coll::Tiers.new(2493)
p JacintheManagement::Coll.fetch_client(2493)

# tiers_type = 2 pour les collectifs
