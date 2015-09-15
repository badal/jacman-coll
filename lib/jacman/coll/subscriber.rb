#!/usr/bin/env ruby
# encoding: utf-8
#
# File: subscriber.rb
# Created: 4 june 2015
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Coll
    TAB = "\t"
    # processor of collective subscriptions
    class Subscriber
      attr_reader :client_list, :registry
      # @param [Collective] collective to process
      # @param [Bool] mode whether write for good in the DB
      def initialize(collective, mode = false)
        @collective = collective
        @tiers_list = []
        @client_list = {}
        @registry = [%w(Type Tiers Client Revue Abont).join(TAB)]
        @base_client_hash = collective.base_client_hash
        @base_subscription_hash = collective.build_base_subscription_hash
        @mode = mode
      end

      # add line to registry
      # @param [Array] ary to be registered
      def register(*ary)
        @registry << ary.join(TAB)
      end

      # build specific client hash
      #
      # @param [Integer] tiers_id
      # @return [Hash] parameter hash for client
      def client_parameters_for(tiers_id)
        name = @collective.name
        tiers_name = Coll.fetch_tiers_name(tiers_id)
        intitule = "'#{tiers_name}/Collectif/#{name}'"
        specific = {
          client_sage_id: "'#{tiers_id}#{name}'",
          client_sage_client_final: "#{tiers_id}",
          client_sage_intitule: intitule,
          client_sage_abrege: "'#{tiers_id}-#{name}'",
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
          puts "Impossible de créer l'abonnement de #{client_id} à #{Coll.journals[journal_id].last}"
        else
          puts "Pas de journal électronique de numéro #{journal_id}"
        end
      end

      # find existing subscriptions
      #
      # @param [Integer|String] tiers_id identifier of tiers
      # @param [Integer|String] journal_id identifier of journal
      # @return [Array<Subscriptions>] all subscriptions for these parameters
      def find_subscriptions(tiers_id, journal_id)
        Coll.all_esubs.select do |item|
          item[:tiers_id].to_i == tiers_id &&
            item[:revue].to_i == journal_id &&
            item[:annee].to_i == @collective.year
        end
      end

      # fill the @client_list hash
      #
      # @param [Array<Integer|String>] list list of tiers identifiers
      # @return [Array<String>] error report if any
      def add_tiers_list(list)
        report = list.map { |tiers_id| add_tiers(tiers_id) }
        report.compact
      end

      # @param [Integer] tiers_id identifier of tiers
      # @return [Array<String>] error report
      def add_tiers(tiers_id)
        client_id = specific_client_for(tiers_id)
        if client_id
          @client_list[tiers_id] = client_id
          @tiers_list << tiers_id
          nil
        else
          "pas de tiers #{tiers_id} ou pas de client pour ce tiers"
        end
      end

      # process all clients
      #
      # @return [Array<String>] report
      def process
        @client_list.each_pair { |pair| process_client(*pair) }
        @registry
      end

      # build, register for this client
      #
      # @param [String] tiers_id identifier of tiers
      # @param [String] client_id identifier of client
      def process_client(tiers_id, client_id)
        new_journal_ids = []
        @collective.journal_ids.each do |journal_id|
          register_existing_subscriptions(tiers_id, journal_id)
          sub_id = build_and_register_subscription(tiers_id, client_id, journal_id)
          new_journal_ids << journal_id if sub_id
        end
      end

      # build and register the new subscription
      #
      # @param [String] tiers_id identifier of tiers
      # @param [String] client_id identifier of client
      # @param [String] journal_id identifier of journal
      # @return [String] identifier of subscription
      def build_and_register_subscription(tiers_id, client_id, journal_id)
        sub_id =  @mode ? build_subscription(client_id, journal_id) : 99_999
        journal = Coll.journals[journal_id].first
        register('NEW', tiers_id, client_id, journal, sub_id.to_i) if sub_id
        sub_id
      end

      # register the old subscriptions with these parameters
      #
      # @param [String] tiers_id identifier of tiers
      # @param [String] journal_id identifier of journal
      def register_existing_subscriptions(tiers_id, journal_id)
        alt_subs = find_subscriptions(tiers_id, journal_id)
        alt_subs.each do |alt_sub|
          alt_sub_id = alt_sub[:abonnement]
          alt_client_id = alt_sub[:client_sage_id]
          journal = Coll.journals[journal_id].first
          register('OLD', tiers_id, alt_client_id, journal, alt_sub_id.to_i)
        end
      end
    end
  end
end
