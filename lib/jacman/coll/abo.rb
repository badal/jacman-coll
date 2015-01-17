#!/usr/bin/env ruby
# encoding: utf-8
#
# File: abo.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Coll
    class Abo
      # TODO: to put in a file
      SQL = 'SELECT client_sage_client_final tiers_id, \
abonnement_client_sage client_sage_id,  tiers_drupal drupal_id, revue_code revue, \
abonnement_annee annee \
FROM abonnement LEFT JOIN revue ON revue_id = abonnement_revue \
LEFT JOIN client_sage ON client_sage_id = abonnement_client_sage \
LEFT JOIN tiers ON client_sage_client_final = tiers_id \
WHERE abonnement_type = 2 \
AND abonnement_annee >= year(now()) - 1 \
AND abonnement_ignorer = 0'

      def self.all
        @all ||= Fetch.new('{SQL};').hashes
        end

      def self.all_institutional
        @all ||= Fetch.new("#{SQL} AND tiers_type = 2;").hashes
      end
    end
  end
end

puts '-------------'
p JacintheManagement::Coll::Abo.all_institutional
puts '-------------'
