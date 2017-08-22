require 'test_helper'

class TextControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get text_index_url
    assert_response :success
  end

end
