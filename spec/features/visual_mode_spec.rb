# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'visual mode', js: true do
  before { open_and_focus_page! }

  context 'forward word' do
    it 'goes forward one word' do
      set_textarea_value_and_selection('|Thing word yeah')

      visual_mode do
        fire 'w'

        expect_textarea_to_have_value_and_selection('|Thing |word yeah')
      end
    end
  end

  context 'forward search' do
    it 'should search all the way to the char inclusive' do
      set_textarea_value_and_selection('|Thing word yeah')

      visual_mode do
        fire 'f'
        fire 'g'

        expect_textarea_to_have_value_and_selection('|Thing| word yeah')
      end
    end
  end

  def visual_mode
    send_os_keys('jk')
    send_os_keys('v')
    yield
  ensure
    send_os_keys(:escape)
    send_os_keys('i')
  end
end
