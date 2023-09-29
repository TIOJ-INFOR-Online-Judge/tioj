require 'test_helper'

class ContestsHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "ranklist_data ioi-style score & freeze is correct" do
    submissions = [
      Submission.new(user_id: 1, problem_id: 1, result: "WA", score: 50),
      Submission.new(user_id: 1, problem_id: 1, result: "AC", score: 70),
      Submission.new(user_id: 1, problem_id: 1, result: "received", score: 0),
      Submission.new(user_id: 1, problem_id: 1, result: "AC", score: 40),
      Submission.new(user_id: 1, problem_id: 1, result: "AC", score: 100), # already freezed
    ]
    start_time = Time.new(2023, 1, 1, 0, 0, 0)
    freeze_start = Time.new(2023, 1, 1, 0, 0, 5)
    submissions.each_with_index {|x, i| x.created_at = start_time + i + 1}
    expected_result = {
      result: {
        "1_1" => [
          {timestamp: 1000000, state: [50, true, 0]},
          {timestamp: 2000000, state: [70, true, 0]},
          {timestamp: 3000000, state: [70, true, 1]},
          {timestamp: 5000000, state: [70, true, 2]},
        ],
      },
      participants: [1],
      first_ac: {1 => 1},
    }
    assert_equal expected_result, ranklist_data(submissions, start_time, freeze_start, 'ioi')
  end

  test "ranklist_data ioi-style negative score is correct" do
    submissions = [
      Submission.new(user_id: 1, problem_id: 1, result: "ER", score: 0),
      Submission.new(user_id: 1, problem_id: 1, result: "WA", score: -10),
      Submission.new(user_id: 1, problem_id: 1, result: "JE", score: 0),
      Submission.new(user_id: 1, problem_id: 2, result: "WA", score: 0),
      Submission.new(user_id: 1, problem_id: 2, result: "WA", score: -10),
      Submission.new(user_id: 1, problem_id: 3, result: "WA", score: -10),
    ]
    start_time = Time.new(2023, 1, 1, 0, 0, 0)
    freeze_start = Time.new(2023, 1, 1, 1, 0, 0)
    submissions.each_with_index {|x, i| x.created_at = start_time + i + 1}
    expected_result = {
      result: {
        "1_1" => [{timestamp: 2000000, state: [-10, true, 0]}],
        "1_2" => [{timestamp: 4000000, state: [0, true, 0]}],
        "1_3" => [{timestamp: 6000000, state: [-10, true, 0]}],
      },
      participants: [1],
      first_ac: {},
    }
    assert_equal expected_result, ranklist_data(submissions, start_time, freeze_start, 'ioi')
  end

  test "ranklist_data ioi-style should not display Validating score" do
    submissions = [
      Submission.new(user_id: 1, problem_id: 1, result: "WA", score: 10),
      Submission.new(user_id: 1, problem_id: 1, result: "Validating", score: 50),
    ]
    start_time = Time.new(2023, 1, 1, 0, 0, 0)
    freeze_start = Time.new(2023, 1, 1, 1, 0, 0)
    submissions.each_with_index {|x, i| x.created_at = start_time + i + 1}
    expected_result = {
      result: {
        "1_1" => [
          {timestamp: 1000000, state: [10, true, 0]},
          {timestamp: 2000000, state: [10, true, 1]},
        ],
      },
      participants: [1],
      first_ac: {},
    }
    assert_equal expected_result, ranklist_data(submissions, start_time, freeze_start, 'ioi')
  end
  
  test "ranklist_data acm-style score & first_ac is correct" do
    submissions = [
      Submission.new(user_id: 1, problem_id: 1, result: "WA", score: 50),
      Submission.new(user_id: 1, problem_id: 1, result: "CLE", score: 70), # CE not count
      Submission.new(user_id: 1, problem_id: 1, result: "queued", score: 70),
      Submission.new(user_id: 1, problem_id: 1, result: "AC", score: 0),
      Submission.new(user_id: 1, problem_id: 1, result: "Validating", score: 70), # should ignore because already AC
      Submission.new(user_id: 1, problem_id: 1, result: "WA", score: 70), # should ignore because already AC
      Submission.new(user_id: 2, problem_id: 1, result: "AC", score: 0),
      Submission.new(user_id: 2, problem_id: 2, result: "AC", score: 70),
      Submission.new(user_id: 1, problem_id: 2, result: "AC", score: 0),
    ]
    start_time = Time.new(2022, 1, 1, 0, 0, 0)
    freeze_start = Time.new(2022, 1, 1, 1, 0, 0)
    submissions.each_with_index {|x, i| x.created_at = start_time + i + 1}
    expected_result = {
      result: {
        "1_1" => [
          {timestamp: 1000000, state: [1, nil, 0]},
          {timestamp: 3000000, state: [1, nil, 1]},
          {timestamp: 4000000, state: [2, 4000000, 0]},
        ],
        "2_1" => [{timestamp: 7000000, state: [1, 7000000, 0]}],
        "1_2" => [{timestamp: 9000000, state: [1, 9000000, 0]}],
        "2_2" => [{timestamp: 8000000, state: [1, 8000000, 0]}],
      },
      participants: [1, 2],
      first_ac: {1 => 1, 2 => 2},
    }
    assert_equal expected_result, ranklist_data(submissions, start_time, freeze_start, 'acm')
  end

  test "ranklist_data acm-style freeze is correct" do
    submissions = [
      Submission.new(user_id: 1, problem_id: 1, result: "WA", score: 50),
      Submission.new(user_id: 1, problem_id: 1, result: "WA", score: 50), # start freeze
      Submission.new(user_id: 2, problem_id: 1, result: "WA", score: 50),
      Submission.new(user_id: 2, problem_id: 1, result: "CE", score: 70), # CE/Validating should also count
      Submission.new(user_id: 2, problem_id: 1, result: "Validating", score: 70),
    ]
    start_time = Time.new(2022, 1, 1, 0, 0, 0)
    freeze_start = Time.new(2022, 1, 1, 0, 0, 2)
    submissions.each_with_index {|x, i| x.created_at = start_time + i + 1}
    expected_result = {
      result: {
        "1_1" => [
          {timestamp: 1000000, state: [1, nil, 0]},
          {timestamp: 2000000, state: [1, nil, 1]},
        ],
        "2_1" => [
          {timestamp: 3000000, state: [0, nil, 1]},
          {timestamp: 4000000, state: [0, nil, 2]},
          {timestamp: 5000000, state: [0, nil, 3]},
        ],
      },
      participants: [1, 2],
      first_ac: {},
    }
    assert_equal expected_result, ranklist_data(submissions, start_time, freeze_start, 'acm')
  end

  test "ranklist_data new-ioi-style score is correct" do
    problem = Problem.new(
      id: 1,
      testdata: Array.new(2){ Testdatum.new() },
      subtasks: [
        Subtask.new(td_list: '0', score: 50),
        Subtask.new(td_list: '1', score: 50),
      ],
    )
    submissions = [
      Submission.new(user_id: 1, problem: problem, result: "WA", score: 50, submission_testdata_results: [
        SubmissionTestdataResult.new(score: 20, position: 0), # weighted score: 10
        SubmissionTestdataResult.new(score: 80, position: 1), # weighted score: 40
      ]),
      Submission.new(user_id: 1, problem: problem, result: "WA", score: 50, submission_testdata_results: [
        SubmissionTestdataResult.new(score: 80, position: 0),
        SubmissionTestdataResult.new(score: 20, position: 1),
      ]),
    ]
    start_time = Time.new(2022, 1, 1, 0, 0, 0)
    freeze_start = Time.new(2022, 1, 1, 1, 0, 0)
    submissions.each_with_index {|x, i| x.created_at = start_time + i + 1}
    submissions.each {|x| x.generate_subtask_result(true)}
    expected_result = {
      result: {
        "1_1" => [
          {timestamp: 1000000, state: [50, true, 0]},
          {timestamp: 2000000, state: [80, true, 0]},
        ],
      },
      participants: [1],
      first_ac: {},
    }
    assert_equal expected_result, ranklist_data(submissions, start_time, freeze_start, 'ioi_new')
  end
  
  test "ranklist_data should count ignored participant" do
    submissions = [
      Submission.new(user_id: 1, problem_id: 1, result: "Validating", score: 0),
      Submission.new(user_id: 2, problem_id: 1, result: "CE", score: 0),
    ]
    start_time = Time.new(2022, 1, 1, 0, 0, 0)
    freeze_start = Time.new(2022, 1, 1, 1, 0, 0)
    submissions.each_with_index {|x, i| x.created_at = start_time + i + 1}
    assert_equal [1, 2], ranklist_data(submissions, start_time, freeze_start, 'acm')[:participants]
    assert_equal [1, 2], ranklist_data(submissions, start_time, freeze_start, 'ioi')[:participants]
  end
end
