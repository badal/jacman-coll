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
      attr_reader :name, :provider
      attr_accessor :journal_ids, :tiers_list, :billing, :year

      # FIXME: choose whether provider is a Client or a client_sage_id

      # @param [String] name of subscription to be used in Jacinthe
      # @param [String] Jacinthe id of Client who provided the coll. subs.
      # @param [String] billing billing for the coll. sub.
      # @param [Array<Integer>] journal_ids list of journals (revue_id)
      # @param [Array<Integer>Object] tiers_list list of subscribers (tiers_id)
      # @param [Integer] year year of coll. sub.
      def initialize(name, provider, billing, journal_ids = [], tiers_list = [], year = YEAR)
        @name = name
        @journal_ids = journal_ids
        @tiers_list = tiers_list
        @base_client_hash = build_base_client_hash(provider)
        @base_subscription_hash = build_base_subscription_hash(name, year, billing)
      end

      def build_base_client_hash(provider)
        unless Coll.fetch_client(provider)
          fail ArgumentError, "Pas de client #{provider}"
        end
        {
            client_sage_compte_collectif: 1,
            client_sage_categorie_comptable: 1,
            client_sage_paiement_chez: "'#{provider}'",
        }
      end

      def build_base_subscription_hash(name, year, billing)
        {
            abonnement_annee: year,
            abonnement_type: 2,
            abonnement_remarque: "'abonnement collectif #{name}'",
            abonnement_facture: "'#{billing}'",
            abonnement_reference_commande: "'ABO#{year.two_digits}-#{name}'"
        }
      end

      # build specific client hash
      #
      # @param [Integer] tiers_id
      # @return [Hash] parameter hash for client
      def client_parameters_for(tiers_id)
        specific = {
            client_sage_id: "'#{tiers_id}#{@name}'",
            client_sage_client_final: "#{tiers_id}",
            client_sage_intitule: "'#{tiers_id}/Collective/#{name}'",
            client_sage_abrege: "'#{tiers_id}-#{@name}'",
           client_sage_livraison_chez: "'#{tiers_id}'"
        }
        @base_client_hash.merge(specific)
      end

      # return client_id of specific client (having created it if necessary)
      #
      # @param [Integer] tiers_id id of tiers
      # @return [String] client_sage_id for the specific client
      def specific_client_for(tiers_id)
        parameters = client_parameters_for(tiers_id)
        client_id = parameters[:client_sage_id]
        cl = Coll.fetch_client(client_id)
        Coll.insert_in_base('client_sage', parameters) unless cl
        client_id
      end

      # build individual subscription hash
      #
      # @param [String] client_id
      # @return [Hash] parameter hash for subscription
      # @param [Integer] journal_id id of journal
      def subscription_parameters_for(client_id, journal_id)
        specific = {
            abonnement_client_sage: "'#{client_id}'",
            abonnement_revue: journal_id,
         }
        @base_subscription_hash.merge(specific)
      end

      # build individual subscription
      def build_subscription(client_id, journal_id)
        parameters = subscription_parameters_for(client_id, journal_id)
        Coll.insert_if_needed('abonnement', parameters)
      end
    end
  end
end

include JacintheManagement
include Coll

coll = CollectiveSubscription.new('ESSAI', '1610', 'FA312')

client = coll.specific_client_for(383)

p client

hsh = coll.subscription_parameters_for('383ESSAI', 2)

p Coll.find('abonnement', hsh)

p Coll.insert_if_needed('abonnement', hsh)
