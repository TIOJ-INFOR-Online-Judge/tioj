require "test_helper"

class ContestListJsonTest < ActionDispatch::IntegrationTest
  test "anonymous contest list omits descriptions before and during contests" do
    upcoming = contests(:two)
    running = contests(:four)
    upcoming.update!(description: "Private upcoming contest instructions")
    running.update!(description: "Private running contest instructions")

    get contests_url(format: :json)
    assert_response :success
    entries = response.parsed_body.index_by { |entry| entry.fetch("id") }
    [upcoming, running].each do |contest|
      entry = entries.fetch(contest.id)
      assert_equal contest.title, entry.fetch("title")
      assert entry.key?("start_time")
      assert entry.key?("end_time")
      assert entry.key?("contest_type")
      assert entry.key?("url")
      assert_not entry.key?("description")
      assert_not_includes response.body, contest.description
    end
  end
end
