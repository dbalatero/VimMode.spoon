RSpec.describe 'big word motion', js: true do
  context 'W' do
    advanced_mode do
      it 'moves to the end of a single line when utf8 chars' do
        value = 'First “line |here.'
        expected = 'First “line here.|'

        expect_textarea_change_in_normal_mode(from: value, to: expected) do
          fire 'W'
        end
      end
    end
  end
end
