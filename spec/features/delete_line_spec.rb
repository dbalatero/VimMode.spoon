# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'delete word', js: true do
  context 'dd' do
    fallback_mode do
      it "deletes a line and stays on the line :(" do
        value = <<~EOF.strip
          Line 1
          Lin|e 2
          Line 3
        EOF

        expected = <<~EOF.strip
          Line 1
          |
          Line 3
        EOF

        expect_textarea_change_in_normal_mode(from: value, to: expected) do
          fire 'dd'
        end
      end

      it "deletes the last line and puts the cursor on the line above" do
        value = <<~EOF.strip
          Line 1
          Lin|e 2
        EOF

        expected = "Line 1\n|"

        expect_textarea_change_in_normal_mode(from: value, to: expected) do
          fire 'dd'
        end
      end
    end

    advanced_mode do
      it "deletes a line and goes down one line" do
        value = <<~EOF.strip
          Line 1
          Lin|e 2
          Line 3
        EOF

        expected = <<~EOF.strip
          Line 1
          |Line 3
        EOF

        expect_textarea_change_in_normal_mode(from: value, to: expected) do
          fire 'dd'
        end
      end

      it "deletes the last line and puts the cursor on the line above" do
        value = <<~EOF.strip
          Line 1
          Lin|e 2
        EOF

        expected = "|Line 1"

        expect_textarea_change_in_normal_mode(from: value, to: expected) do
          fire 'dd'
        end
      end
    end
  end
end
