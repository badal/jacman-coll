#!/usr/bin/env ruby
# encoding: utf-8
#
# File: coll.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

utils =  File.expand_path('../../../jacman-utils/lib/jacman/utils.rb')

require utils

# require 'set'

require_relative 'coll/version.rb'
require_relative 'coll/fetch.rb'
require_relative 'coll/globals.rb'
require_relative 'coll/collective.rb'

SQLError = Class.new(ArgumentError)
