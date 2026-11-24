require "application_system_test_case"

class ContestDashboardTest < ApplicationSystemTestCase
  setup do
    @contest = contests(:one)
    @problem = problems(:one)
    @contest.contest_problem_joints.create!(problem: @problem)
    @owner = users(:userOne)
    @other = users(:userTwo)
  end

  test "IOI dashboard orders scores, highlights self, and replays earlier results" do
    add_submission(@owner, 10, "WA", 30)
    add_submission(@other, 20, "WA", 60)
    add_submission(@owner, 30, "AC", 100)
    sign_in @owner
    visit dashboard_contest_path(@contest)

    assert_selector "#dashboard_table_body tr:first-child#row_user_#{@owner.id}.table-self"
    assert_selector "#cell_score_user_#{@owner.id}", exact_text: "100"
    assert_selector "#cell_score_user_#{@other.id}", exact_text: "60"

    # Drive the slider's real slide callback at 25 minutes into the contest.
    page.execute_script("const slider = $('#ranklist_time_slider'); slider.slider('option', 'slide')(null, {value: 1500});")
    assert_selector "#ranklist_time", exact_text: "0:25:00"
    assert_selector "#dashboard_table_body tr:first-child#row_user_#{@other.id}"
    assert_selector "#cell_score_user_#{@owner.id}", exact_text: "30"

    click_link "Force Refresh"
    assert_selector "#dashboard_table_body tr:first-child#row_user_#{@owner.id}.table-self"
  end

  test "ACM dashboard counts failed attempts and orders equal solves by penalty" do
    @contest.update!(contest_type: :acm)
    add_submission(@owner, 10, "WA", 0)
    add_submission(@other, 15, "AC", 100)
    add_submission(@owner, 25, "AC", 100)
    visit dashboard_contest_path(@contest)

    assert_selector "#dashboard_table_body tr:first-child#row_user_#{@other.id}"
    assert_selector "#cell_solved_user_#{@owner.id}", exact_text: "1"
    assert_selector "#cell_penalty_user_#{@owner.id}", exact_text: "45"
    assert_selector "#cell_penalty_user_#{@other.id}", exact_text: "15"
    assert_selector "#cell_item_user_#{@owner.id}_#{@problem.id}", exact_text: "2/25"
  end

  private

  def add_submission(user, minutes, result, score)
    source = submissions(:ac)
    @contest.submissions.create!(user: user, problem: @problem, compiler: source.compiler,
      code_content: source.code_content, code_length: source.code_length,
      result: result, score: score, created_at: @contest.start_time + minutes.minutes)
  end
end
