#!/usr/bin/env ruby
# -*- ruby -*-

require './config/environment'

no_fed_splits = PrecinctSplit.all.map do |s|
  district_types = s.district_set.districts.map(&:district_type).map(&:title)
  s.id unless district_types.include?("Congressional")
end.compact

# [26, 283, 836, 881, 1112, 1491, 1578, 1754, 1781, 1817, 1924, 2058, 2100, 2328, 2372, 2407, 2530, 2596]
# in console
# PrecinctSplit.find(2407).district_set.districts.map(&:district_type).map(&:title)
# Only PrecinctSplit.find(2407) has contests.
# PrecinctSplit.find_by_display_name("501758-202 - TEMPERANCE-0001" )
puts "not federal splits = #{no_fed_splits.inspect}"
