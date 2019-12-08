# frozen_string_literal: true

module TextHelpers
  def send_normal_mode_keys(key_strokes)
    send_os_keys('jk')
    sleep 0.01

    send_os_keys(key_strokes)
    sleep 0.01

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
    range = get_range_from_string(string)
    expect(get_selection_range).to eq(range)
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

  def send_os_keys(*keys)
    Array(keys).each do |strokes|
      cmd = [
        'osascript <<EOF',
        'tell application "System Events"',
        '  keystroke "' + strokes + '"',
        'end tell',
        'EOF'
      ].join("\n")

      system(cmd)
    end
  end
end

RSpec.configure do |config|
  config.include TextHelpers
end
