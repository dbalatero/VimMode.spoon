# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'visual mode', js: true do
  before { open_and_focus_page! }

  context 'forward word' do
    it 'goes forward one word' do
      set_textarea_value_and_selection('|Thing word yeah')

      enter_visual!
      send_os_keys 'w'

      expect_textarea_to_have_value_and_selection('|Thing |word yeah')
    end
  end

  def enter_visual!
    send_os_keys('jk', 'v')
  end
end
