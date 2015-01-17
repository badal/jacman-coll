#!/usr/bin/env ruby
# encoding: utf-8

# File: cnrs.rb
# Created: 26/12/2014
#
# (c) Michel Demazure <michel@demazure.com>
begin
  CNRS = JacintheManagement::Coll::CollectiveSubscription.new('1610')

  CNRS.journal_ids = [1, 2, 6, 17]

  p CNRS
rescue ArgumentError => err
  p err

end
