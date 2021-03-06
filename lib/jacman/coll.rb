#!/usr/bin/env ruby
# encoding: utf-8
#
# File: coll.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

# require 'set'

require_relative 'coll/version.rb'
require_relative 'coll/fetch.rb'
require_relative 'coll/globals.rb'
require_relative 'coll/collective.rb'
require_relative 'coll/subscriber.rb'

SQLError = Class.new(ArgumentError)

module JacintheManagement
  # tools for collective subscriptions management
  module Coll
    HELP_FILE = File.join(File.dirname(__FILE__), '..', '..', 'help/help.pdf')
  end
end
