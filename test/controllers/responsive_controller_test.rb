require 'test_helper'

class ResponsiveControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get responsive_index_url
    assert_response :success
  end

end
