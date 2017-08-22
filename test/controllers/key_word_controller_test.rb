require 'test_helper'

class KeyWordControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get key_word_index_url
    assert_response :success
  end

end
