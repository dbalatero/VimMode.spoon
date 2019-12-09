RSpec.configure do |config|
  config.before :suite do
    result = `ps aux | grep 'Google Chrome' | grep -v grep`.strip

    unless result.empty?
      puts "==> Killing running instance of Chrome, we can't have both running"
      system("killall 'Google Chrome'")
    end
  end
end
