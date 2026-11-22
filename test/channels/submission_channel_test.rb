require "test_helper"

class SubmissionChannelTest < ActionCable::Channel::TestCase
  setup do
    stub_connection current_user: nil, single_contest: nil
    @public_submission = submissions(:ac)
    @hidden_submission = submissions(:invisible)
    [@public_submission, @hidden_submission].each do |submission|
      submission.create_submission_subtask_result!(result: [])
    end
  end

  test "anonymous visitor cannot subscribe to a hidden problem submission" do
    subscribe id: @hidden_submission.id
    assert_rejected_without_data(@hidden_submission)
  end

  test "ordinary user cannot subscribe to a hidden problem submission" do
    stub_connection current_user: users(:userOne), single_contest: nil
    subscribe id: @hidden_submission.id
    assert_rejected_without_data(@hidden_submission)
  end

  test "anonymous visitor can subscribe to a public problem submission" do
    subscribe id: @public_submission.id
    assert subscription.confirmed?
    assert_has_stream "submission_#{@public_submission.id}_overall_nojce"
    assert_equal 1, broadcasts("submission_#{@public_submission.id}_overall_nojce").size
  end

  test "admin can subscribe to a hidden problem submission" do
    stub_connection current_user: users(:adminOne), single_contest: nil
    subscribe id: @hidden_submission.id
    assert subscription.confirmed?
    assert_has_stream "submission_#{@hidden_submission.id}_overall"
  end

  test "batch subscription excludes hidden submissions" do
    subscribe id: [@public_submission.id, @hidden_submission.id]
    assert subscription.confirmed?
    assert_equal ["submission_#{@public_submission.id}_overall_nojce"], subscription.streams
    assert_empty broadcasts("submission_#{@hidden_submission.id}_overall_nojce")
  end

  test "batch subscription with only hidden submissions is rejected" do
    subscribe id: [@hidden_submission.id]
    assert_rejected_without_data(@hidden_submission)
  end

  test "contest-only problem cannot be accessed through a non-contest submission" do
    @public_submission.problem.update!(visible_state: :contest)
    subscribe id: @public_submission.id
    assert_rejected_without_data(@public_submission)
  end

  test "contest-only problem cannot be accessed before contest starts even by its submitter" do
    @public_submission.problem.update!(visible_state: :contest)
    @public_submission.update!(contest: contests(:two))
    stub_connection current_user: @public_submission.user, single_contest: nil
    subscribe id: @public_submission.id
    assert_rejected_without_data(@public_submission)
  end

  test "contest-only problem is accessible to its submitter after contest starts" do
    @public_submission.problem.update!(visible_state: :contest)
    @public_submission.update!(contest: contests(:four))
    stub_connection current_user: @public_submission.user, single_contest: nil
    subscribe id: @public_submission.id
    assert subscription.confirmed?
    assert_has_stream "submission_#{@public_submission.id}_overall_nojce"
  end

  test "running contest still prevents viewing another users submission" do
    @public_submission.update!(contest: contests(:four))
    subscribe id: @public_submission.id
    assert_rejected_without_data(@public_submission)
  end

  test "admin in single-contest mode cannot bypass hidden problem visibility" do
    @hidden_submission.update!(contest: contests(:four))
    stub_connection current_user: users(:adminOne), single_contest: contests(:four)
    subscribe id: @hidden_submission.id
    assert_rejected_without_data(@hidden_submission)
  end

  test "single-contest connection cannot subscribe to another contests submission" do
    stub_connection current_user: users(:adminOne), single_contest: contests(:four)
    subscribe id: @public_submission.id
    assert_rejected_without_data(@public_submission)
  end

  private

  def assert_rejected_without_data(submission_record)
    assert subscription.rejected?
    assert_no_streams
    %w[subtasks testdata overall overall_nojce].each do |suffix|
      assert_empty broadcasts("submission_#{submission_record.id}_#{suffix}")
    end
  end
end
