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

  test "should get new" do
    sign_in @user_one
    get new_team_url
    assert_response :success
  end

  test "should create team" do
    sign_in @user_one
    assert_difference("Team.count") do
      post teams_url, params: { team: { teamname: "New_Team_123", school: "New School" } }
    end
    assert_redirected_to team_url(Team.last)
  end
end
