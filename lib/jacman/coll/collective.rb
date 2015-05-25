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
      attr_reader :name, :client_list, :registry
      attr_accessor :journal_ids, :billing, :year

      # @param [String] name of subscription to be used in Jacinthe
      # @param [String] provider Jacinthe id of Client who provided the coll. subs.
      # @param [String] billing billing for the coll. sub.
      # @param [Array<Integer>] journal_ids list of journals (revue_id)
      # @param [Array<Integer>Object] tiers_list list of subscribers (tiers_id)
      # @param [Integer] year year of coll. sub.
      def initialize(name, provider, billing = 'NULL', journal_ids = [], year = YEAR)
        @name = name
        @journal_ids = journal_ids
        @client_list = {}
        @registry = []
        @year = year
        @base_client_hash = build_base_client_hash(provider)
        @base_subscription_hash = build_base_subscription_hash(name, billing)
      end

      def register(type, tiers_id, client_id, revue_id, abonnement_id)
        @registry << [type, tiers_id, client_id, revue_id, abonnement_id]
      end

      def register(*ary)
        @registry << ary
      end

      # TODO: write method
      def save_registry
        p @registry
      end

      def build_base_client_hash(provider)
        unless Coll.fetch_client(provider)
          fail ArgumentError, "Pas de client #{provider}"
        end
        {
            client_sage_compte_collectif: 1,
            client_sage_categorie_comptable: 1,
            client_sage_paiement_chez: "'#{provider}'"
        }
      end

      def build_base_subscription_hash(name, billing)
        {
            abonnement_annee: year,
            abonnement_type: 2,
            abonnement_remarque: "'abonnement collectif #{name}'",
            abonnement_facture: "'#{billing}'",
            abonnement_reference_commande: "'ABO#{@year.two_digits}-#{name}'"
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
            client_sage_intitule: "'#{tiers_id}/Collectif/#{name}'",
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
      rescue SQLError
        nil
      end

      # build individual subscription hash
      #
      # @param [String] client_id
      # @return [Hash] parameter hash for subscription
      # @param [Integer] journal_id id of journal
      def subscription_parameters_for(client_id, journal_id)
        specific = {
            abonnement_client_sage: client_id,
            abonnement_revue: journal_id
        }
        @base_subscription_hash.merge(specific)
      end

      # build individual subscription
      def build_subscription(client_id, journal_id)
        parameters = subscription_parameters_for(client_id, journal_id)
        Coll.insert_if_needed('abonnement', parameters)
      rescue SQLError
        if Coll.journals[journal_id]
          puts "Impossible de créer l'abonnement à #{Coll.journals[journal_id]}"
        else
          puts "Pas de journal électronique de numéro #{journal_id}"
        end
      end

      # TODO: comment
      def find_subscription(tiers_id, journal_id)
        ESub.all.select do |item|
          item[:tiers_id].to_i == tiers_id &&
              item[:revue].to_i == journal_id &&
              item[:annee].to_i == @year
        end
      end

      # TODO: comment
      def add_tiers_list(list)
        report = []
        list.each do |tiers_id|
          client_id = specific_client_for(tiers_id)
          if client_id
            @client_list[tiers_id] = client_id
          else
            report << "pas de tiers #{tiers_id } ou pas de client pour ce tiers"
          end
        end
        report
      end

      # TODO: comment
      def process
        @client_list.each_pair { |tiers_id, client_id| process_client(tiers_id, client_id) }
        p @registry
      end

      # TODO: comment
      def process_client(tiers_id, client_id)
        @journal_ids.each do |journal_id|
          sub_id = build_subscription(client_id, journal_id)
          alt_subs = find_subscription(tiers_id, journal_id)
          register("NEW", tiers_id, client_id, journal_id, sub_id) if sub_id
          alt_subs.each do |alt_sub|
            alt_sub_id = alt_sub[:abonnement]
            return if sub_id && alt_sub_id == sub_id
            alt_client_id = alt_sub[:client_sage_id]
            register("OLD", tiers_id, alt_client_id, journal_id, alt_sub_id)
          end
        end
      end
    end
  end
end
