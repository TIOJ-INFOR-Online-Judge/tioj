require "test_helper"

class SubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Submission.all.each do |sub|
      sub.generate_subtask_result
      sub.save
    end
    @submission = submissions(:ac)
    @submission_invisible = submissions(:invisible)
    @problem = problems(:one)
  end

  test "should get index" do
    get submissions_url
    assert_response :success
    get problem_submissions_url(@problem)
    assert_response :success
  end

  test "should get submission" do
    get submission_url(@submission)
    assert_response :success
  end

  test "submission visibility should be correct" do
    assert_raise ActionController::RoutingError do
      get submission_url(@submission_invisible)
    end

    sign_in users(:userOne)
    assert_raise ActionController::RoutingError do
      get submission_url(@submission_invisible)
    end
    sign_out :user

    sign_in users(:adminOne)
    get submission_url(@submission_invisible)
    assert_response :success
  end

  test "should create submission" do
    post problem_submissions_url(@problem), params: {submission: {
      compiler_id: compilers(:c99).id,
      code_content_attributes: {code: "somecode"}
    }}
    assert_login_needed

    sign_in users(:userOne)
    assert_difference(["Submission.count", "SubmissionSubtaskResult.count", "CodeContent.count"]) do
      post problem_submissions_url(@problem), params: {submission: {
        compiler_id: compilers(:c99).id,
        code_content_attributes: {code: "somecode"}
      }}
    end
    assert_response :redirect
    assert_match /\/submissions\/[0-9]+/, @response.redirect_url
  end

  test "should get edit" do
    sign_in users(:adminOne)
    get edit_submission_url(@submission)
    assert_response :success
  end

  test "should update submission" do
    sign_in users(:adminOne)
    code = "anothercode"
    patch submission_url(@submission), params: {submission: {
      compiler_id: compilers(:c99).id,
      code_content_attributes: {code: code, id: @submission.code_content_id}
    }}
    @submission.reload
    assert_response :redirect
    assert_equal @submission.code_content.code, code
    assert_equal @submission.code_length, code.length
    assert_match /\/submissions\/[0-9]+/, @response.redirect_url
  end

  test "should destroy submission" do
    sign_in users(:adminOne)
    assert_difference("Submission.count", -1) do
      delete submission_url(@submission)
    end
    assert_response :redirect
  end

  test "normal user should not edit submission" do
    sign_in users(:userOne)

    patch submission_url(@submission), params: {submission: {
      compiler_id: compilers(:c99).id,
      code_content_attributes: {code: "code", id: @submission.code_content_id}
    }}
    assert_no_permission
  end
end
