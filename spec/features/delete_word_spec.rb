# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'delete word', js: true do
  context 'dw' do
    fallback_mode do
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

    advanced_mode do
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
