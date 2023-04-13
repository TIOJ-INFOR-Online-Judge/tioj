require "test_helper"

Selenium::WebDriver.logger.output = 'tmp/selenium.log'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
  include SystemSignInHelper

  # removes noisy logs when launching tests
  Capybara.server = :puma, { Silent: true }
end
