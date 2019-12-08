# frozen_string_literal: true

module TextHelpers
  def fire(key_strokes)
    send_os_keys(key_strokes)
  end

  def normal_mode
    send_os_keys('jk')
    sleep 0.01

    yield
    sleep 0.01
  ensure
    send_os_keys('i')
  end

  def open_and_focus_page!
    path = File.expand_path(File.dirname(__FILE__) + '/../fixtures')

    visit "file://#{path}/textarea.html"
    expect(page).to have_css('textarea:focus')

    patch_chrome_for_accessibility!
  end

  def set_textarea_value_and_selection(value)
    range = get_range_from_string(value)
    value = remove_range_chars(value)

    fill_in 'area', with: value
    page.execute_script("document.getElementById('area').focus()")
    set_selection_range(range['start'], range['finish'])
  end

  def expect_textarea_to_have_value_and_selection(range)
    text = remove_range_chars(range)

    expect_textarea_to_have_value(text)
    expect_to_have_selection_range(range)
  end

  def set_selection_range(start, finish)
    page.execute_script <<~EOF
      document.getElementById('area').setSelectionRange(#{start}, #{finish});
    EOF
  end

  def expect_textarea_to_have_value(text)
    textarea = find_textarea
    wait_for { textarea.value == text }
  rescue StandardError
    expect(textarea.value).to eq(text)
  end

  def remove_range_chars(string)
    string.gsub('|', '')
  end

  def get_range_from_string(string)
    pipe_indexes = get_indexes_of(string, '|')

    raise ArgumentError, 'at least 1 pipe char required' if pipe_indexes.empty?
    raise ArgumentError, 'only 2 pipe chars max allowed' if pipe_indexes.length > 2

    range = {
      'start' => pipe_indexes.first,
      'finish' => pipe_indexes.first
    }

    range['finish'] = pipe_indexes[1] - 1 if pipe_indexes[1]

    range
  end

  def expect_to_have_selection_range(string)
    expect(current_value_with_selection_range).to eq(string)
  end

  def current_value_with_selection_range
    value = find_textarea.value.dup
    range = get_selection_range

    value.insert(range['start'], '|')
    value.insert(range['finish'], '|') if range['start'] != range['finish']

    value
  end

  def get_selection_range
    result = page.evaluate_script <<~EOF
      {
        start: document.activeElement.selectionStart,
        finish: document.activeElement.selectionEnd
      }
    EOF
  end

  def get_indexes_of(string, char)
    i = -1
    indexes = []

    while i = string.index(char, i + 1)
      indexes << i
    end

    indexes
  end

  def find_textarea
    page.first('textarea')
  end

  def wait_for(&block)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        break if block.call

        sleep 0.01
      end
    end
  end

  def patch_chrome_for_accessibility!
    script = <<~CMD
      osascript <<EOF
        tell application "System Events"
          tell process "Google Chrome"
            set value of attribute "AXEnhancedUserInterface" to true
          end tell
        end tell
      EOF
    CMD

    system(script)
  end

  class Keystroke
    def initialize(strokes)
      @strokes = strokes
    end

    def to_applescript
      "keystroke \"#{@strokes}\""
    end
  end

  class Keycode
    def initialize(code)
      @code = code
    end

    def to_applescript
      "key code #{@code}"
    end
  end

  SPECIAL_CHARS = {
    escape: Keycode.new(53)
  }.freeze

  def send_os_keys(*keys)
    events = Array(keys).map do |stroke|
      SPECIAL_CHARS[stroke] || Keystroke.new(stroke)
    end

    code = events
           .map { |event| "    #{event.to_applescript}" }
           .join("\n")

    cmd = <<~CMD
      osascript <<EOF
        tell application "System Events"
      #{code}
        end tell
      EOF
    CMD

    system(cmd)
  end
end

RSpec.configure do |config|
  config.include TextHelpers
end
