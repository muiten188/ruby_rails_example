require 'test_helper'

class ClipControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get clip_index_url
    assert_response :success
  end

end
