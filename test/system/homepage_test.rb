require "application_system_test_case"

class HomepageTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit '/'
    assert_selector "h1, h2, h3, h4, h5, h6", text: "Bulletin Board"
  end
end
