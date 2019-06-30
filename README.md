# VimMode.spoon

🚀 This library will add Vim motions and operators to all your input fields on
OS X. Why should Emacs users have all the fun? Not all motions or operators
are implemented, but I tried to at least hit the major ones I use day-to-day!

My goal was to make this library fairly easy to drop in, even if you aren't
currently running Hammerspoon. I welcome any PRs or additions to extend
the motions and/or operators that are supported.

This is my first Lua library, so things might be a little weird :)

## Progress

### Motions

- [x] `shift + a` - jump to end of line
- [x] `shift + g` - jump to last line of input
- [x] `shift + i` - jump to beginning of line
- [x] `0` - beginning of line
- [x] `$` - end of line
- [x] `b` - back by word
- [ ] `f<char>` - jump to next instance of `<char>` - requires context we don't have
- [ ] `F<char>` - jump to prev instance of `<char>` - requires context we don't have
- [ ] `t<char>` - jump to before next instance of `<char>` - requires context we don't have
- [ ] `T<char>` - jump to before prev instance of `<char>` - requires context we don't have
- [x] `w` fwd by word
- [x] `hjkl` - arrow keys

### Operators

- [x] `shift + c` - delete to end of line, exit normal mode
- [x] `shift + d` delete to end of line
- [x] `c` - delete and exit normal mode
- [x] `d` - delete
- [ ] `cc` - delete line and enter insert mode
- [x] `dd` - delete line
- [ ] `r<char>` to replace - currently broken
- [x] `x` to delete char under cursor

### Other

- [x] `i` to go back to insert mode
- [x] `o` - add new line below, exit normal mode
- [x] `shift + o` - add new line above, exit normal mode
- [x] `p` to paste
- [x] `s` to delete under cursor, exit normal mode
- [x] `u` to undo
- [x] `y` to yank to clipboard
- [x] `/` to trigger `cmd+f` search
- [x] visual mode with `v`
- [ ] support prefixing commands with numbers to repeat them (e.g. `2dw`)

## Usage

* To enter normal mode, hit whichever key you bind to it (typically `jj`, `jk`, or `hyper`)
* The screen should slightly dim when you enter normal mode.
* To exit normal mode, press `i` - business as usual.

## Prerequisites

* Install [Hammerspoon](http://www.hammerspoon.org/go/)

## Installation

Run this in your Terminal:

```
mkdir -p ~/.hammerspoon/Spoons
git clone https://github.com/dbalatero/VimMode.spoon \
  ~/.hammerspoon/Spoons/VimMode.spoon
```

Modify your `~/.hammerspoon/init.lua` file to contain the following:

```lua
vim = hs.loadSpoon('VimMode')

-- Basic key binding to ctrl+;
-- You can choose any key binding you want here, see:
--   https://www.hammerspoon.org/docs/hs.hotkey.html#bind

hs.hotkey.bind({'ctrl'}, ';', function()
  vim:enter()
end)
```

## Binding jk to enter Vim Mode

```lua
vim = hs.loadSpoon('VimMode')

vim:enableKeySequence('j', 'k')
```

You can also use modifiers in this sequence:

```lua
-- requires shift to be held down when you type jk
vim:enableKeySequence('j', 'k', {'shift'})
```

## Disabling vim mode for certain apps

You probably want to disable this Vim mode in the terminal, or any actual
instance of Vim. Calling `vim:disableForApp(...)` allows you to disable or
enable Vim mode depending on which window is in focus.

```
vim = hs.loadSpoon('VimMode')

-- sometimes you need to check Activity Monitor to get the app's
-- real name
vim:disableForApp('Code')
vim:disableForApp('iTerm')
vim:disableForApp('MacVim')
vim:disableForApp('Terminal')
```
