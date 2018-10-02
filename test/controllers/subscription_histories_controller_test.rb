require 'test_helper'

class SubscriptionHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subscription_history = subscription_histories(:one)
  end

  test "should get index" do
    get subscription_histories_url, as: :json
    assert_response :success
  end

  test "should create subscription_history" do
    assert_difference('SubscriptionHistory.count') do
      post subscription_histories_url, params: { subscription_history: { canceled_times: @subscription_history.canceled_times } }, as: :json
    end

    assert_response 201
  end

  test "should show subscription_history" do
    get subscription_history_url(@subscription_history), as: :json
    assert_response :success
  end

  test "should update subscription_history" do
    patch subscription_history_url(@subscription_history), params: { subscription_history: { canceled_times: @subscription_history.canceled_times } }, as: :json
    assert_response 200
  end

  test "should destroy subscription_history" do
    assert_difference('SubscriptionHistory.count', -1) do
      delete subscription_history_url(@subscription_history), as: :json
    end

    assert_response 204
  end
end
