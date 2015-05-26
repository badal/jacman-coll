#!/usr/bin/env ruby
# encoding: utf-8
#
# File: notifier.rb
# Created: 26 may 2015
#
# (c) Michel Demazure <michel@demazure.com>
module JacintheManagement
  module Coll
    class DummySubscription

      attr_reader :id
      def initialize(sub_id)
        @id = sub_id.to_s
        @name = Coll.journals[sub_id]
      end

      # WARNING: only necessary if model files use "REVUES"
      def report
        @name
      end
    end

    class Notifier < JacintheManagement::Notifications::Notifier

      def initialize(tiers_id, sub_ids)
        subs = sub_ids.map do |sub_id|
          Coll::DummySubscription.new(sub_id)
        end
        super(tiers_id, subs)
      end

      def french_model_file
        super
      end

      def english_model_file
        super
      end

    end
  end

end
