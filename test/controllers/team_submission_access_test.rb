require "test_helper"

class TeamSubmissionAccessTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:four)
    @viewer = users(:userOne)
    @registration = contest_registrations(:one)
    @own_submission = submissions(:team_submission_one)
    @teammate_submission = submissions(:team_submission_two)
    @teammate_submission.generate_subtask_result
    @teammate_submission.save!
    sign_in @viewer
    # Persist the login before exercising endpoints that raise a 404.
    get contest_url(@contest)
    assert_response :success
  end

  test "pending teammate cannot read source or see teammates in the running contest list" do
    @registration.update!(approved: false)

    get raw_contest_submission_url(@contest, @teammate_submission)
    assert_response :not_found
    assert_only_own_submission_listed

    get raw_contest_submission_url(@contest, @own_submission)
    assert_response :success
    assert_equal @own_submission.code_content.code, response.body
  end

  test "revoking approval removes existing teammate access" do
    get raw_contest_submission_url(@contest, @teammate_submission)
    assert_response :success
    assert_equal @teammate_submission.code_content.code, response.body
    get contest_submissions_url(@contest)
    assert_response :success
    assert_select "td", text: users(:userTwo).nickname, count: 1

    @registration.update!(approved: false)
    get raw_contest_submission_url(@contest, @teammate_submission)
    assert_response :not_found
    assert_only_own_submission_listed
  end

  test "pending teammate cannot view the submission page" do
    @registration.update!(approved: false)
    get contest_submission_url(@contest, @teammate_submission)
    assert_response :not_found
  end

  test "unapproved teammate cannot bypass the frozen scoreboard after the contest" do
    @registration.update!(approved: false)
    @contest.update!(start_time: 2.hours.ago, end_time: 1.hour.ago,
                     register_before: 2.hours.ago, freeze_minutes: 30)
    [@own_submission, @teammate_submission].each do |submission|
      submission.update!(created_at: @contest.end_time - 15.minutes)
    end

    get raw_contest_submission_url(@contest, @teammate_submission)
    assert_response :not_found
    get contest_submissions_url(@contest)
    assert_response :success
    assert_select "td", text: users(:userTwo).nickname, count: 0
    assert_select "td", text: @viewer.nickname, count: 1
  end

  test "admin retains access to teammate source" do
    @registration.update!(approved: false)
    sign_out :user
    sign_in users(:adminOne)
    get raw_contest_submission_url(@contest, @teammate_submission)
    assert_response :success
    assert_equal @teammate_submission.code_content.code, response.body
  end

  private

  def assert_only_own_submission_listed
    get contest_submissions_url(@contest)
    assert_response :success
    assert_select "td", text: @viewer.nickname, count: 1
    assert_select "td", text: users(:userTwo).nickname, count: 0
  end
end
