require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  include SystemSignInHelper

  # removes noisy logs when launching tests
  Capybara.server = :puma, { Silent: true }

  teardown do
    # check JavaScript errors
    assert_empty page.driver.browser.logs.get(:browser).select{|x| x.level == 'SEVERE'}
  end
end
