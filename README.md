# VimMode.spoon

This library will add Vim motions and operators to all your input fields on
OS X. Not all motions and operators are probably implemented, but I tried to
at least hit the major ones I use day-to-day!

# TODO

- [ ] support prefixing commands with numbers to repeat them (e.g. `2dw`)

# Usage

* To enter normal mode, hit whichever key you bind to it.
* The screen should slightly dim when you enter normal mode.
* To exit normal mode, press `i` - business as usual.

# Installation

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

# Binding jk to enter Vim Mode

```lua
vim = hs.loadSpoon('VimMode')

vim:enableKeySequence('j', 'k')
```

You can also use modifiers in this sequence:

```lua
-- requires shift to be held down when you type jk
vim:enableKeySequence('j', 'k', {'shift'})
```

# Disabling vim mode for certain apps

You probably want to disable this Vim mode in the terminal, or any actual 
instance of Vim. Calling `vim:disableForApp(...)` allows you to disable or
enable Vim mode depending on which window is in focus.

```
vim = hs.loadSpoon('VimMode')

vim:disableForApp('iTerm2')
vim:disableForApp('MacVim')
vim:disableForApp('Terminal')
```
