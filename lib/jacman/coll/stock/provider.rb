#!/usr/bin/env ruby
# encoding: utf-8
#
# File: provider.rb
# Created: 16 january 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Coll
    class Provider
      # FIXME: keys of table being integers, table could be an array
      # FIXME: yes, but it can be convenient to keep subscribers which are not yet Tiers
      attr_accessor :table
      def initialize(client_sage_id, _table = nil)
        @client = Coll.fetch_client(client_sage_id)
      end

      def name
        @client[:client_sage_abrege]
      end
    end
  end
end
