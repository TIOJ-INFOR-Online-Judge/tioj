require "application_system_test_case"

class ContestRegistrationsTest < ApplicationSystemTestCase
  setup do
    @contest = contests(:one)
  end

  test "visiting the index" do
    sign_in users(:adminOne)
    visit contest_contest_registrations_url(@contest)
    assert_selector "h1", text: "Contest registrations"
  end
end
