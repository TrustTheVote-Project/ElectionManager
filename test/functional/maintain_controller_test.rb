require 'test_helper'

class MaintainControllerTest < ActionController::TestCase
  
  test "should import batch yml" do
    get(:import_batch, {'import_folder_path' => 'test/elections/','commit' => 'YML files'})
    assert_equal 'Election import was successful. Here is your new election.', flash[:notice]
  end
  
  test "should import batch xml" do
    get(:import_batch, {'import_folder_path' => 'test/elections/','commit' => 'XML files'})
    assert_equal 'Election import was successful. Here is your new election.', flash[:notice]
  end
  
end
