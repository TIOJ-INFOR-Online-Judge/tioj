ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
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
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end