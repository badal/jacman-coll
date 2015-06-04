#!/usr/bin/env ruby
# encoding: utf-8
#
# File: collective.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

# reopening base class
class Fixnum
  # @return [String] the last two digits
  def two_digits
    format('%02d', self % 100)
  end
end

module JacintheManagement
  module Coll
    # collective electronic subscriptions
    class CollectiveSubscription
      TAB = "\t"
      attr_reader :name
      attr_accessor :journal_ids, :billing, :year

      # @param [String] name of subscription to be used in Jacinthe
      # @param [String] provider Jacinthe id of Client who provided the coll. subs.
      # @param [String] billing billing for the coll. sub.
      # @param [Array<Integer>] journal_ids list of journals (revue_id)
      # @param [Integer] year year of coll. sub.
      def initialize(name, provider, billing = 'NULL', journal_ids = [], year = YEAR)
        @name = name
        @provider = provider
        @billing = billing
        @journal_ids = journal_ids
        @year = year
        unless Coll.fetch_client(@provider)
          fail ArgumentError, " Pas de client #{@provider}"
        end
      end

      def self.from_hash(hsh)
        new(hsh[:collectif_nom],
            hsh[:collectif_client],
            hsh[:collectif_facture],
            hsh[:collectif_revues].split(',').map(&:to_i),
            hsh[:collectif_annee].to_i)
      end

      def self.number
        Fetch.new('select count(*) from collectif').array.last.last.to_i
      end

      def self.extract(indx)
        from_hash(Fetch.item('collectif', indx))
      end

      def insertion_query
        ["INSERT IGNORE INTO collectif SET collectif_nom = '#{@name}'",
         "collectif_client = '#{@provider}'",
         "collectif_annee = #{@year}",
         "collectif_facture = '#{@billing}'",
         "collectif_revues = '#{@journal_ids.join(',')}'"
        ].join(', ')
      end

      def base_client_hash
        {
            client_sage_compte_collectif: 1,
            client_sage_categorie_comptable: 1,
            client_sage_paiement_chez: "'#{@provider}'"
        }
      end

      def build_base_subscription_hash
        {
            abonnement_annee: year,
            abonnement_type: 2,
            abonnement_remarque: "'abonnement collectif #{@name}'",
            abonnement_facture: "'#{@billing}'",
            abonnement_reference_commande: "'ABO#{@year.two_digits}-#{@name}'"
        }
      end
    end
  end
end
