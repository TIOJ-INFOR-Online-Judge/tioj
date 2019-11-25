require "application_system_test_case"

class HomepageTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit '/'
    assert_selector "h5", text: "Bulletin Board"
  end
end
