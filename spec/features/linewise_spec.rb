# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'linewise movements', js: true do
  before { open_and_focus_page! }

  context 'moving up' do
    it 'goes up and maintains column position' do
      set_textarea_value_and_selection <<~EOF
        My line 1
        My |line 2
      EOF

      normal_mode do
        fire 'k'

        expect_textarea_to_have_value_and_selection <<~EOF
          My |line 1
          My line 2
        EOF
      end
    end
  end

  context 'moving down' do
    it 'goes down and maintains column position' do
      set_textarea_value_and_selection <<~EOF
        My |line 1
        My line 2
      EOF

      normal_mode do
        fire 'j'

        expect_textarea_to_have_value_and_selection <<~EOF
          My line 1
          My |line 2
        EOF
      end
    end
  end
end
