#!/usr/bin/env ruby
# -*- ruby -*-

require './config/environment'

DistrictType.all.map(&:title)

fed_dt = DistrictType.find_by_title("Congressional")

fed_district_ids = District.find_all_by_district_type_id(fed_dt.id).map(&:id).sort
puts "fed_district_ids = #{fed_district_ids.inspect}"
fed_district_id = fed_district_ids.first
puts "fed_district_id = #{fed_district_id.inspect}"

fed_contest_id = Contest.all.map{ |c| c.id if c.district.id == fed_district_id}.compact.first
puts "fed_contest_id = #{fed_contest_id.inspect}"

fed_district_set_ids = DistrictSet.all.map do |ds|
  ds.id if ds.districts.map(&:id).include?(fed_district_id)
end.compact
puts "fed_district_set_ids = #{fed_district_set_ids.inspect}"
fed_district_set_id = fed_district_set_ids.first
puts "fed_district_set_id = #{fed_district_set_id.inspect}"


precinct_split = PrecinctSplit.find_by_district_set_id(fed_district_set_id)
precinct_split_id  = precinct_split.id
puts "precinct_split_id = #{precinct_split_id.inspect}"
puts "precinct_split display name = #{precinct_split.display_name.inspect}"

va_election = Election.last
ballot_contests = precinct_split.ballot_contests(va_election)
puts "ballot contests = #{ballot_contests.inspect}"

