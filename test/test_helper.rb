ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Selenium::WebDriver.logger.output = 'tmp/selenium.log'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module SystemSignInHelper
  def sign_in(user)
    visit '/users/sign_in'
    # username same as password since we can't store plain password in fixtures
    fill_in "Username", with: user.username
    fill_in "Password", with: user.username

    click_button "Sign in" 
    assert_text "Signed in successfully"
  end

  def sign_in_admin(user)
    visit '/admin/login'
    # username same as password since we can't store plain password in fixtures
    fill_in "Username", with: user.username
    fill_in "Password", with: user.username

    click_button "Login"
    assert_text "Signed in successfully"
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def assert_no_permission
    assert_response :redirect
    assert_equal flash[:alert], 'Insufficient User Permissions.'
  end

  def assert_login_needed
    assert_redirected_to '/users/sign_in'
  end
end