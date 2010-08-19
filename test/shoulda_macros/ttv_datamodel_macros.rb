#
# Macros to create various structured Precincts, PrecinctSplits, DistrictSets and Districts
#
class Test::Unit::TestCase
  def setup_precinct name, count
    district_counts = [3, 4, 2, 5, 7]
    assert count <= district_counts.length
    @prec_new = Precinct.create :display_name => name
    (0..count-1).each do |i|
      setup_precinct_split("#{name} Split #{i}", (i == 0) ? 0 : district_counts[i-1], district_counts[i])
      @prec_new.precinct_splits << @prec_split_new
    end
    @prec_new.save
    @prec_new
  end
  
  def setup_precinct_split name, from, to
    setup_districtset name, from, to
    @prec_split_new = PrecinctSplit.create! :display_name => name
    @prec_split_new.district_set = @district_set_new
    @prec_split_new.save
    @prec_split_new
  end
    
  def setup_districtset name, from, to
    @district_set_new = DistrictSet.make(:display_name => name)
    (from..to-1).each do |i|
      @district_set_new.districts << District.create!(:display_name => "#{name} District #{i}", :district_type => DistrictType::COUNTY)
      assert @district_set_new.valid?
    end
    @district_set_new.save
    @district_set_new
  end
end
