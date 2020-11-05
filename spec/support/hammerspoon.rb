# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    # Refresh Hammerspoon
    system('killall Hammerspoon 2>/dev/null')
    exit 1 unless system('open -a Hammerspoon')

    puts
    puts '==> Restarted Hammerspoon, sleeping 1 second...'
    puts

    sleep 1
  end
end
