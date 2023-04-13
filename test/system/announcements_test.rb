require "application_system_test_case"

class AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @announcement = announcements(:one)
  end

  test "visiting the index" do
    sign_in users(:adminOne)
    visit announcements_url
    assert_selector "h4", text: "Announcements"
    assert_selector "h4", text: "New Announcement"
  end

  test "should create announcement" do
    sign_in users(:adminOne)
    visit announcements_url

    fill_in "Body", with: @announcement.body
    fill_in "Title", with: @announcement.title
    click_on "Create Announcement"

    assert_text "Announcement was successfully created"
    click_on "Back"
  end

  test "should update Announcement" do
    sign_in users(:adminOne)
    visit announcements_url
    click_on "Edit", match: :first

    fill_in "Body", with: @announcement.body
    fill_in "Title", with: @announcement.title
    click_on "Update Announcement"

    assert_text "Announcement was successfully updated"
  end

  test "should destroy Announcement" do
    sign_in users(:adminOne)
    visit announcements_url

    accept_alert do
      click_on "Destroy", match: :first
    end

    assert_text "Announcement was successfully destroyed"
  end
end
