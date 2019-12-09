# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'deletion', js: true do
  context 'dw' do
    context 'fallback mode' do
      before { open_and_focus_page! mode: "fallback" }

      it 'deletes a single word value' do
        expect_textarea_change_in_normal_mode(from: '|Word', to: "|") do
          fire('dw')
        end
      end

      it 'deletes from the middle of a word to the end' do
        expect_textarea_change_in_normal_mode(from: "W|ord a", to: "W| a") do
          fire('dw')
        end
      end
    end

    context 'advanced mode' do
      before { open_and_focus_page! mode: "advanced" }

      it 'deletes a single word value' do
        expect_textarea_change_in_normal_mode(from: '|Word', to: '|') do
          fire('dw')
        end
      end

      it 'deletes from the middle of a word' do
        expect_textarea_change_in_normal_mode(from: 'W|ord', to: 'W|') do
          fire('dw')
        end
      end

      it 'handles multiple words' do
        expect_textarea_change_in_normal_mode(
          from: '|Word another',
          to: '|another'
        ) do
          fire('dw')
        end
      end
    end
  end
end
