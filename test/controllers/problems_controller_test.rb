require "test_helper"

class ProblemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @problem = problems(:one)
    @problem_invisible = problems(:invisible)
  end

  test "should get index" do
    get problems_url
    assert_response :success
  end

  test "should get problem" do
    get problem_url(@problem)
    assert_response :success
  end

  test "problem visibility should be correct" do
    assert_raise ActionController::RoutingError do
      get problem_url(@problem_invisible)
    end

    sign_in users(:userOne)
    assert_raise ActionController::RoutingError do
      get problem_url(@problem_invisible)
    end
    sign_out :user

    sign_in users(:adminOne)
    get problem_url(@problem_invisible)
    assert_response :success
  end

  test "should get ranklist" do
    get ranklist_problem_url(@problem)
    assert_response :success
  end

  test "should create problem" do
    sign_in users(:adminOne)
    assert_difference("Problem.count") do
      post problems_url, params: {problem: @problem.attributes.except('id')}
    end
    assert_response :redirect
    assert_match /\/problems\/[0-9]+/, @response.redirect_url
  end

  test "should get edit" do
    sign_in users(:adminOne)
    get edit_problem_url(@problem)
    assert_response :success
  end

  test "should update problem" do
    sign_in users(:adminOne)
    patch problem_url(@problem), params: { problem: { name: @problem.name } }
    assert_response :redirect
    assert_match /\/problems\/[0-9]+/, @response.redirect_url
  end

  test "should not destroy problem" do
    sign_in users(:adminOne)
    assert_difference("Problem.count", 0) do
      delete problem_url(@problem)
    end
    assert_response :redirect
  end

  test "normal user should not edit problems" do
    sign_in users(:userOne)

    post problems_url, params: {problem: @problem.attributes.except('id')}
    assert_no_permission
    patch problem_url(@problem), params: { problem: { name: @problem.name } }
    assert_no_permission
  end
end
