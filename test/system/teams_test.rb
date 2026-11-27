require "application_system_test_case"

class TeamsTest < ApplicationSystemTestCase
  test "team list highlights the teams the current user belongs to" do
    team = teams(:one)

    sign_in users(:userThree)
    outsider_style = team_row_style(team)
    click_link "Sign out"

    sign_in users(:userOne)
    member_style = team_row_style(team)

    assert_not_equal outsider_style, member_style,
      "a team the user belongs to should be visually highlighted"
  end

  private

  # Rendered background of the team's row, covering both plain backgrounds and
  # Bootstrap 5's inset box-shadow table variants.
  def team_row_style(team)
    visit teams_path
    row = find("tr", text: team.name)
    # Keep the pointer off the table so :hover styles do not leak in.
    page.driver.browser.action.move_to_location(0, 0).perform
    row.evaluate_script(<<~JS)
      Array.from(this.cells).map((cell) => {
        const style = getComputedStyle(cell);
        return [style.backgroundColor, style.boxShadow].join(" | ");
      })
    JS
  end
end
