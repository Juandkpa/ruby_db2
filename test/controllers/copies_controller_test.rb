require 'test_helper'

class CopiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @copy = copies(:one)
  end

  test "should get index" do
    get copies_url, as: :json
    assert_response :success
  end

  test "should create copy" do
    assert_difference('Copy.count') do
      post copies_url, params: { copy: { code: @copy.code, place: @copy.place } }, as: :json
    end

    assert_response 201
  end

  test "should show copy" do
    get copy_url(@copy), as: :json
    assert_response :success
  end

  test "should update copy" do
    patch copy_url(@copy), params: { copy: { code: @copy.code, place: @copy.place } }, as: :json
    assert_response 200
  end

  test "should destroy copy" do
    assert_difference('Copy.count', -1) do
      delete copy_url(@copy), as: :json
    end

    assert_response 204
  end
end
