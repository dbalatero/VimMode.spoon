# frozen_string_literal: true

require 'capybara/rspec'
require 'webdrivers/chromedriver'

Capybara.default_max_wait_time = 2

Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.new(
    chromeOptions: {
      args: %w[
        disable-default-apps
        force-renderer-accessibility
        no-default-browser-check
        no-first-run
      ]
    }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.javascript_driver = :chrome
