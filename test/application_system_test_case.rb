require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
    # Keep Chrome's password prompts from intercepting input after fixture logins.
    options.add_preference("credentials_enable_service", false)
    options.add_preference("profile.password_manager_enabled", false)
    options.add_preference("profile.password_manager_leak_detection", false)
  end
  include SystemSignInHelper

  # removes noisy logs when launching tests
  Capybara.server = :puma, { Silent: true }

  def teardown
    # check JavaScript errors
    assert_empty page.driver.browser.logs.get(:browser).select{|x| x.level == 'SEVERE'}
  ensure
    # Chrome rejects the wildcard origin Capybara 3.40 uses to reset a reused session.
    page.quit
    super
  end
end
