#!/usr/bin/env ruby
# encoding: utf-8
#
# File: e_sub.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Coll
    # current electronic subscriptions
    class ESub
      # TODO: to put in a file
      SQL_INITIAL = 'SELECT client_sage_client_final tiers_id,
abonnement_client_sage client_sage_id,  tiers_drupal drupal_id, revue_code revue,
abonnement_annee annee
FROM abonnement LEFT JOIN revue ON revue_id = abonnement_revue
LEFT JOIN client_sage ON client_sage_id = abonnement_client_sage
LEFT JOIN tiers ON client_sage_client_final = tiers_id
WHERE abonnement_type = 2
AND abonnement_annee >= year(now()) - 1
AND abonnement_ignorer = 0'.gsub("\n", ' ')

      Query = <<ESQL
SELECT client_sage_client_final tiers_id,
abonnement_client_sage client_sage_id, revue_id revue,
abonnement_annee annee, abonnement_id abonnement
FROM abonnement LEFT JOIN revue ON revue_id = abonnement_revue
LEFT JOIN client_sage ON client_sage_id = abonnement_client_sage
LEFT JOIN tiers ON client_sage_client_final = tiers_id
WHERE abonnement_type = 2
AND abonnement_annee >= year(now()) - 1
AND abonnement_ignorer = 0
ESQL

      # @return [Array<Hash>] all electronic e_subs as hashes
      def self.all
        @all ||= Fetch.new(Query.gsub!("\n", ' ')).hashes
      end

      # @return [Array<Hash>] all institutional electronic e_subs as hashes
      def self.all_institutional
        @all ||= Fetch.new("#{SQL_INITIAL} AND tiers_type = 2;").hashes
      end
    end
  end
end

