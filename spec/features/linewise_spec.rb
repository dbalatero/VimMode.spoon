# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'linewise movements', js: true do
  context 'moving up' do
    fallback_mode do
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

    advanced_mode do
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
  end

  context 'moving down' do
    fallback_mode do
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

    advanced_mode do
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
end
