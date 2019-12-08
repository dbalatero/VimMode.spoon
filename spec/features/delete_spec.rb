# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'deletion', js: true do
  before { open_and_focus_page! }

  context 'words' do
    it 'deletes a single word value' do
      set_textarea_value_and_selection('|Word')

      normal_mode do
        fire('dw')

        expect_textarea_to_have_value_and_selection('|')
      end
    end

    it 'deletes from the middle of a word' do
      set_textarea_value_and_selection('W|ord')

      normal_mode do
        fire('dw')

        expect_textarea_to_have_value_and_selection('W|')
      end
    end

    it 'handles multiple words' do
      set_textarea_value_and_selection('|Word another')

      normal_mode do
        fire('dw')

        expect_textarea_to_have_value_and_selection('|another')
      end
    end
  end
end
