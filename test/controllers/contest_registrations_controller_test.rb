require "test_helper"

class ContestRegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:one)
    @batch_new_params = {contest_registrations_controller_create_form: {
      num_start: 1,
      num_end: 3,
      username_format: 'user%d',
      nickname_format: 'user%d',
      password_length: 6,
    }}
  end

  test "should get index" do
    sign_in users(:adminOne)
    get contest_contest_registrations_url(@contest)
    assert_response :success
  end

  test "registered teams table keeps every member row in one body" do
    contest = contests(:four)
    sign_in users(:adminOne)
    get contest_contest_registrations_url(contest)
    assert_response :success

    # Parse like a browser does: a stray </tbody> splits later rows into implicit bodies.
    document = Nokogiri::HTML5(response.body)
    table = document.xpath("//table[.//*[normalize-space()='Unregister All']]").first
    assert table, "registered teams table should be rendered"

    member_rows = table.css("tr").select { |row| row.at_css("a[data-method='patch']") }
    assert_equal 2, member_rows.size
    assert_equal 1, table.css("tbody").size
    assert_equal 1, member_rows.map(&:parent).uniq.size
  end

  test "should get new" do
    sign_in users(:adminOne)
    get batch_new_contest_contest_registrations_url(@contest)
    assert_response :success
  end

  test "batch create and delete contest users" do
    sign_in users(:adminOne)
    assert_difference("ContestUser.count", 3) do
      post batch_new_contest_contest_registrations_url(@contest), params: @batch_new_params
    end
    assert_response :success

    assert_difference("ContestUser.count", -3) do
      post batch_op_contest_contest_registrations_url(@contest), params: {action_type: 'delete_contest_users'}
    end
    assert_redirected_to contest_contest_registrations_url(@contest)
  end

  test "visibility correct" do
    sign_in users(:userOne)
    get contest_contest_registrations_url(@contest)
    assert_no_permission

    get batch_new_contest_contest_registrations_url(@contest)
    assert_no_permission
  end

  # test "should destroy contest_registration" do
  #   assert_difference("ContestRegistration.count", -1) do
  #     delete contest_registration_url(@contest_registration)
  #   end

  #   assert_redirected_to contest_registrations_url
  # end
end
