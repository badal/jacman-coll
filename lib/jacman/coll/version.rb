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
    MINOR = 4
    TINY = 0

    VERSION = [MAJOR, MINOR, TINY].join('.')
  end
end

if $PROGRAM_NAME == __FILE__

  puts JacintheManagement::Coll::VERSION

end
