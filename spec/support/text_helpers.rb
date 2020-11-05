# frozen_string_literal: true

module TextHelpers
  def fire(key_strokes)
    send_os_keys key_strokes
    sleep 0.025
  end

  def normal_mode
    fire('jk')
    sleep 0.1

    yield
    sleep 0.01
  ensure
    fire('i')
    sleep 0.01
  end

  def open_and_focus_page!(mode: 'advanced')
    path = File.expand_path(File.dirname(__FILE__) + '/../fixtures')
    visit "file://#{path}/textarea.html"

    system('ps aux | cat')

    puts
    puts
    puts '==> Waiting for textarea'

    expect(page).to have_css('textarea:focus')

    set_chrome_accessibility!(mode == 'advanced')
    sleep 0.1
  end

  def expect_textarea_change_in_normal_mode(from:, to:)
    set_textarea_value_and_selection from

    normal_mode do
      yield
      sleep 0.1
      expect_textarea_to_have_value_and_selection to
    end
  end

  def set_textarea_value_and_selection(value)
    range = get_range_from_string(value)
    value = remove_range_chars(value)

    fill_in 'area', with: value

    page.execute_script("document.getElementById('area').focus()")
    sleep 0.005

    set_selection_range(range['start'], range['finish'])
    sleep 0.01
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

    sleep 0.01
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
    value.insert(range['finish'] + 1, '|') if range['start'] != range['finish']

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

  def set_chrome_accessibility!(value = true)
    value = value ? 'true' : 'false'

    script = <<~CMD
      osascript <<EOF
        tell application "System Events"
          tell process "Google Chrome"
            set value of attribute "AXEnhancedUserInterface" to #{value}
          end tell
        end tell
      EOF
    CMD

    puts '==> Setting chrome accessibility'

    system(script)

    puts '    Done!'
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

module ModeHelpers
  def fallback_mode(&block)
    context 'fallback mode', fallback: true do
      before { open_and_focus_page! mode: 'fallback' }

      instance_exec(&block)
    end
  end

  def advanced_mode(&block)
    context 'advanced mode', advanced: true do
      before { open_and_focus_page! mode: 'advanced' }

      instance_exec(&block)
    end
  end
end

RSpec.configure do |config|
  config.include TextHelpers
  config.extend ModeHelpers
end
