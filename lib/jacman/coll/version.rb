#!/usr/bin/env ruby
# encoding: utf-8
#
# File: version.rb
# Created: 26 December 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module Coll
    MAJOR = 0
    MINOR = 7
    TINY = 1

    VERSION = [MAJOR, MINOR, TINY].join('.')
  end
end

puts JacintheManagement::Coll::VERSION if $PROGRAM_NAME == __FILE__
