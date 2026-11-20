require "application_system_test_case"

class SubmissionMessagesTest < ApplicationSystemTestCase
  test "a user can expand a live judge message in its testdata row" do
    submission = submissions(:ac)
    submission.submission_testdata_results.delete_all
    submission.update_self_with_subtask_result(result: "queued")
    sign_in users(:userOne)
    visit submission_path(submission)
    assert_selector "#waiting-icon"
    assert_no_selector "#td-row-0 .indicator"

    # Deliver the same payload the page receives from SubmissionChannel.
    page.execute_script(<<~JS)
      updateSubmissionDetail({testdata: [{
        position: 0, time: "1.0", rss: 1000, score: "0", result: "WA",
        message_type: "text", message: "Expected a different answer"
      }]});
    JS
    assert_no_selector "#td-message-0", visible: true
    find("#td-row-0 .indicator").click
    assert_selector "#td-message-0", visible: true, text: "Expected a different answer"
  end

  test "an admin can discover an existing message on another user's submission" do
    submission = submissions(:ac)
    submission_testdata_results(:ac_1).update!(message_type: "text", message: "Judge details")
    submission.generate_subtask_result
    sign_in users(:adminOne)
    visit submission_path(submission)

    find("#td-row-0 .indicator", visible: true).click
    assert_selector "#td-message-0", text: "Judge details"
  end

  test "a teammate sees no expander for a hidden judge message" do
    submission = submissions(:team_submission_one)
    submission.submission_testdata_results.create!(position: 0, result: "AC", time: 1, rss: 1000,
      score: 100, message_type: "text", message: "Judge details")
    submission.generate_subtask_result
    sign_in users(:userTwo)
    visit contest_submission_path(submission.contest, submission)

    assert_selector "#td-row-0"
    assert_no_selector "#td-row-0 .indicator"
    assert_no_text "Judge details"
  end
end
