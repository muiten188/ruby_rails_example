require 'test_helper'

class BannerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get banner_index_url
    assert_response :success
  end

end
