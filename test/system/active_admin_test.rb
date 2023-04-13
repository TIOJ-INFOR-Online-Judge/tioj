require "application_system_test_case"

class AnnouncementsTest < ApplicationSystemTestCase
  setup do
    @announcement = announcements(:one)
  end

  test "visiting pages" do
    sign_in_admin admin_users(:admin)

    pages = [
      [admin_root_url, "Dashboard"],
      [admin_admin_users_url, "Admin Users"],
      [admin_articles_url, "Articles"],
      [admin_contests_url, "Contests"],
      [admin_judge_servers_url, "Judge Servers"],
      [admin_problems_url, "Problems"],
      [admin_submissions_url, "Submissions"],
      [admin_testdata_url, "Testdata"],
      [admin_users_url, "Users"],
    ]
    pages.each do |url, title|
      visit url
      assert_selector "h2", text: title
    end
  end

  test "change user to admin" do
    sign_in_admin admin_users(:admin)

    # Usernames are case-insensitive
    visit admin_users_url
    row = page.find(:css, 'td.col-username', text: /^userOne$/i).find(:xpath, './parent::tr')
    assert row.find(:css, 'td.col-user_type').text == "normal_user"

    row.find(:css, 'a.edit_link').click
    select "Admin", :from => "User type"
    click_button "Update User"

    visit admin_users_url
    row = page.find(:css, 'td.col-username', text: /^userOne$/i).find(:xpath, './parent::tr')
    assert row.find(:css, 'td.col-user_type').text == "admin"
  end
end
