require "test_helper"

class ContestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest_one = contests(:one)
    @contest_two = contests(:two)
    @contest_three = contests(:three)
    @user_one = users(:userOne)
    @user_two = users(:userTwo)
    @team_one = teams(:one)
    @admin_one = users(:adminOne)
  end

  test "should get index" do
    get contests_url
    assert_response :success
  end

  test "should show contest" do
    get contest_url(@contest_one)
    assert_response :success
  end

  test "should get new" do
    sign_in @admin_one
    get new_contest_url
    assert_response :success
  end

  test "should register as individual" do
    sign_in @user_one
    post register_update_contest_url(@contest_two)
    assert_response :redirect
    assert_not_nil @contest_two.find_registration(@user_one)
  end

  test "should register as team" do
    sign_in @user_one
    post register_update_contest_url(@contest_three), params: { team_id: @team_one.id }
    assert_response :redirect
    registration = @contest_three.find_registration(@user_one)
    assert_not_nil registration
    assert_equal @team_one, registration.team
  end

  test "should not register as team if not allowed" do
    sign_in @user_one
    post register_update_contest_url(@contest_two), params: { team_id: @team_one.id }
    assert_response :redirect
    assert_nil @contest_two.find_registration(@user_one)
  end

  test "should unregister" do
    sign_in @user_one
    post register_update_contest_url(@contest_two)
    assert_not_nil @contest_two.find_registration(@user_one)
    post register_update_contest_url(@contest_two), params: { cancel: '1' }
    assert_response :redirect
    assert_nil @contest_two.find_registration(@user_one)
  end

  test "should get dashboard" do
    sign_in @admin_one
    get dashboard_contest_url(@contest_one)
    assert_response :success

    sign_in @user_one
    get dashboard_contest_url(@contest_one)
    assert_response :success
  end
end
