require 'test_helper'
require 'pp'
require 'ttv/yaml_export'


class YAMLExportTest < ActiveSupport::TestCase
  
  def imp_exp path
    import_obj = TTV::YAMLImport.new(File.new(path))
    @imp_object = import_obj.import
    @export_obj = TTV::YAMLExport.new(@imp_object)

  end
  
  context "import tiny.yml and try to export it back" do
    setup do
      imp_exp("/mydev/ElectionManager/test/elections/tiny.yml")
    end
    
    should "export tiny correctly and safely" do
      @export_obj.do_export
      res_hash = @export_obj.election_hash
      assert_equal "One Contest Election", res_hash["display_name"]
      assert_equal 1, res_hash["precinct_list"].length
      assert_equal "City of Random", res_hash["precinct_list"][0]["district_list"][0]["display_name"]
    end
    
    context "also import generated.yml and try to export it back" do
      setup do
        imp_exp("/mydev/ElectionManager/test/elections/generated.yml")
      end
      
      should "export generated.yml back correctly too" do
        @export_obj.do_export
        res_hash = @export_obj.election_hash
      end
    end
  end
end

