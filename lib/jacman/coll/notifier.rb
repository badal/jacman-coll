#!/usr/bin/env ruby
# encoding: utf-8
#
# File: notifier.rb
# Created: 26 may 2015
#
# (c) Michel Demazure <michel@demazure.com>
module JacintheManagement
  Notifications::FAKE = true

  module Coll
    class DummySubscription
      attr_reader :id, :report

      def initialize(journal_id)
        @id = journal_id.to_s
        @report = Coll.journals[journal_id.to_i].last
      end
    end

    class Notifier < JacintheManagement::Notifications::Notifier
      CNRS_MODEL_FILE = File.join(Core::MODEL_DIR, 'cnrs_french_model_mail.txt')

      def initialize(tiers_id, journal_ids)
        subs = journal_ids.map do |jrl_id|
          Coll::DummySubscription.new(jrl_id)
        end
        super(tiers_id, subs)
      end

      def french_model_file
        CNRS_MODEL_FILE
      end

      # FIXME: write file
      def english_model_file
        super
      end
    end
  end
end
