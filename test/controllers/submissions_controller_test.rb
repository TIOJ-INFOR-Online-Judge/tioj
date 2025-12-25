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
    @contest_four = contests(:four) # Contest allowing team registration
    @user_one = users(:userOne)
    @user_two = users(:userTwo)
    @user_three = users(:userThree)
    @team_one = teams(:one) # Team with userOne and userTwo
    @problem_one = problems(:one)

    @team_submission_one = submissions(:team_submission_one)
    @team_submission_two = submissions(:team_submission_two)
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
    get submission_url(@submission_invisible)
    assert_response :missing

    sign_in users(:userOne)
    get submission_url(@submission_invisible)
    assert_response :missing
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

  test "should allow team members to view each other's submissions" do
    # userOne should be able to view userTwo's submission
    sign_in @user_one
    get submission_url(@team_submission_two)
    assert_redirected_to contest_submission_url(@contest_four, @team_submission_two)
    sign_out :user

    # userTwo should be able to view userOne's submission
    sign_in @user_two
    get submission_url(@team_submission_one)
    assert_redirected_to contest_submission_url(@contest_four, @team_submission_one)
    sign_out :user
  end

  test "should not allow non-team members to view submissions" do
    # userThree (not in team_one) should not be able to view userOne's submission
    sign_in @user_three
    get submission_url(@team_submission_one)
    assert_response :not_found
  end

  test "should show team members submissions in index" do
    sign_in @user_one
    get contest_submissions_url(@contest_four)
    assert_response :success
    assert_select "td", { text: @user_one.nickname, count: 1 }
    assert_select "td", { text: @user_two.nickname, count: 1 }
    assert_select "td", { text: @user_three.nickname, count: 0 } # Ensure userThree's submission is not visible
    sign_out :user

    sign_in @user_two
    get contest_submissions_url(@contest_four)
    assert_response :success
    assert_select "td", { text: @user_one.nickname, count: 1 }
    assert_select "td", { text: @user_two.nickname, count: 1 }
    assert_select "td", { text: @user_three.nickname, count: 0 } # Ensure userThree's submission is not visible
    sign_out :user
  end

  test "should not show non-team members submissions in index" do
    sign_in @user_three
    get contest_submissions_url(@contest_four)
    assert_response :success
    assert_select "td", { text: @user_one.nickname, count: 0 } # userOne's submission should not be visible
    assert_select "td", { text: @user_two.nickname, count: 0 } # userTwo's submission should not be visible
    assert_select "td", { text: @user_three.nickname, count: 1 }
  end
end
