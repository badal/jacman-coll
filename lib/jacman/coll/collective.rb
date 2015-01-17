#!/usr/bin/env ruby
# encoding: utf-8
#
# File: collective.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Coll
    class CollectiveSubscription
      # FIXME: keys of table being integers, table could be an array
      # FIXME: yes, but it can be convenient to keep subscribers which are not yet Tiers

      attr_accessor :journal_ids, :table, :billing
      def initialize(client_id, billing = nil, journal_ids = [], table = {}, year = YEAR)
        @client = Coll.fetch_client(client_id)
        @journal_ids = journal_ids
        @table = table
        @billing = billing
        @year = year
      end

      def name
        @client[:client_sage_abrege]
      end

      def remark
        "IP_#{name}"
      end

      def reference
        "ref_#{name}"
      end
    end
  end
end
