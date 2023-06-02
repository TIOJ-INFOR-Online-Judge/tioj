require "test_helper"

class ContestRegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:one)
  end

  test "should get index" do
    sign_in users(:adminOne)
    get contest_contest_registrations_url(@contest)
    assert_response :success
  end

  test "should get new" do
    sign_in users(:adminOne)
    get new_contest_contest_registration_url(@contest)
    assert_response :success
  end

  # test "should create contest_registration" do
  #   assert_difference("ContestRegistration.count") do
  #     post contest_registrations_url, params: { contest_registration: {  } }
  #   end

  #   assert_redirected_to contest_registration_url(ContestRegistration.last)
  # end

  test "visibility correct" do
    sign_in users(:userOne)
    get contest_contest_registrations_url(@contest)
    assert_no_permission
    
    get new_contest_contest_registration_url(@contest)
    assert_no_permission
  end

  # test "should destroy contest_registration" do
  #   assert_difference("ContestRegistration.count", -1) do
  #     delete contest_registration_url(@contest_registration)
  #   end

  #   assert_redirected_to contest_registrations_url
  # end
end
