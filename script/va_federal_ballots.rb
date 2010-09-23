#!/usr/bin/env ruby
# -*- ruby -*-

require './config/environment'

# config = YAML.load( ERB.new(File.read("config/database.yml")).result)
# ActiveRecord::Base.establish_connection( config['development'])

DistrictType.all.map(&:title)

fed_dt = DistrictType.find_by_title("Congressional")

fed_district_ids = District.find_all_by_district_type_id(fed_dt.id).map(&:id)
puts "fed_district_ids = #{fed_district_ids.inspect}"

fed_splits = PrecinctSplit.all.map do |split|
  split if (split.district_set.districts.map(&:id) & fed_district_ids).empty?
end.compact

fed_splits_ids = PrecinctSplit.all.map do |split|
  split.district_set.districts.map(&:id) & fed_district_ids
end.flatten.compact.uniq

puts "fed_precinct_splits = #{fed_splits.map(&:display_name).inspect}"

# fed_contests = Contest.all.map do |c|
#   c if fed_district_ids.include?(c.district_id)
# end.compact
# puts "\nfed_contests = #{fed_contests.map(&:display_name).inspect}"

fed_contests = Contest.all.map{ |c| c if c.district.district_type.title == "Congressional"}.compact
puts "fed_contests = #{fed_contests.map(&:display_name).inspect}"

fed_splits_contests = fed_splits & fed_contests

fed_contests_ids = Contest.all.map{ |c| c.district.id if c.district.district_type.title == "Congressional"}.compact

puts "\nfed_precinct_splits ids = #{fed_splits.map(&:id).inspect}"
puts "fed_precinct_splits_ids = #{fed_splits_ids.sort.inspect}"
puts "fed_contests_ids = #{fed_contests_ids.sort.inspect}"


puts "\nIntersection of precinct splits with federal districts and contests in federal districts  = #{fed_splits_contests.inspect}"
