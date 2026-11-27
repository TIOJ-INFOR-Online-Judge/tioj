require "test_helper"

class TeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_one = users(:userOne)
    @team_one = teams(:one)
  end

  test "should get index" do
    sign_in @user_one
    get teams_url
    assert_response :success
  end

  test "should show team" do
    sign_in @user_one
    get team_url(@team_one)
    assert_response :success
  end

  test "team member table keeps every member row in one body" do
    sign_in @user_one
    get team_url(@team_one)
    assert_response :success

    # Parse like a browser does: a stray </tbody> splits later rows into implicit bodies.
    document = Nokogiri::HTML5(response.body)
    table = document.xpath("//table[.//th[normalize-space()='Username']]").first
    assert table, "team member table should be rendered"

    member_rows = table.css("tr").select { |row| row.at_css("td") }
    assert_equal @team_one.users.count, member_rows.size
    assert_equal 1, table.css("tbody").size
    assert_equal 1, member_rows.map(&:parent).uniq.size
  end

  test "should get new" do
    sign_in @user_one
    get new_team_url
    assert_response :success
  end

  test "should create team" do
    sign_in @user_one
    assert_difference("Team.count") do
      post teams_url, params: { team: { name: "New_Team_123", school: "New School" } }
    end
    assert_redirected_to team_url(Team.last)
  end
end
