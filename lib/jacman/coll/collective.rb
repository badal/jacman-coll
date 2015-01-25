#!/usr/bin/env ruby
# encoding: utf-8
#
# File: collective.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Coll
    # collective electronic subscriptions
    class CollectiveSubscription
      attr_reader :name, :provider
      attr_accessor :journal_ids, :tiers_list, :billing, :year

      # @param [String] name of subscription to be used in Jacinthe
      # @param [String] Jacinthe id of Client who provided the coll. subs.
      # @param [String] billing billing for the coll. sub.
      # @param [Array<Integer>] journal_ids list of journals (revue_id)
      # @param [Array<Integer>Object] tiers_list list of subscribers (tiers_id)
      # @param [Integer] year year of coll. sub.
      def initialize(name, provider, billing = nil, journal_ids = [], tiers_list = [], year = YEAR)
        @name = name
        @provider = provider
        @journal_ids = journal_ids
        @tiers_list = tiers_list
        @billing = billing
        @year = year
      end

      # build specific client and return client_id
      # for *existing* tiers
      # @param [Integer] tiers_id
      def client_hash_for(tiers_id)
        {
            client_sage_id: "'#{tiers_id}#{@name}'",
            client_sage_client_final: "#{tiers_id}",
            client_sage_intitule: "'#{tiers_id}/Collective/#{name}'",
            client_sage_abrege: "'#{tiers_id}-#{@name}'",
            client_sage_compte_collectif: 1,
            client_sage_categorie_comptable: 1,
            client_sage_paiement_chez: "'#{@provider}'",
            client_sage_livraison_chez: "'#{tiers_id}'"
        }
      end

      def client_for(tiers_id)
        hsh = client_hash_for(tiers_id)
        cl = Coll.fetch_client(hsh[:client_sage_id])
        return cl if cl
        Coll.insert_in_base('client_sage', hsh)
        Coll.fetch_client(hsh[:client_sage_id])
      end

      # build individual subscription
      def build_subscription(revue, client)

      end

      def remark
        "Coll_#{name}"
      end

      def reference
        "Coll_#{name}"
      end


    end
  end
end

include JacintheManagement
include Coll

coll = CollectiveSubscription.new('ESSAI3', '1610')

client = coll.client_for(383)

p client
