# VimMode.spoon

[![Build Status](https://travis-ci.com/dbalatero/VimMode.spoon.svg?branch=master)](https://travis-ci.com/dbalatero/VimMode.spoon)

🚀 This library will add Vim motions and operators to all your input fields on
OS X. Why should Emacs users have all the fun?

Not all motions or operators are implemented, but you can open an issue if
you're missing something.

The plugin will not work with system inputs marked as secure, such as password
fields or anything in 1Password, as it can't read those fields!

## Table of Contents

* [Quick Installation](#quick-installation)
* [Usage](#usage)
* [Current Support](#current-support)
  - [Flavors of VimMode](#flavors-of-vimmode)
  - [Motions](#motions)
  - [Operators](#operators)
  - [Other](#other)
* [Configuration](#configuration)
  - [Binding jk to enter normal mode](#binding-jk-to-enter-normal-mode)
  - [Binding a single keystroke to enter normal mode](#binding-a-single-keystroke-to-enter-normal-mode)
  - [Disabling vim mode for certain apps](#disabling-vim-mode-for-certain-apps)
  - [Disabling the floating alert when you enter Vim mode(s)](#disabling-the-floating-alert-when-you-enter-vim-modes)
  - [Enabling screen dim when you enter normal mode](#enabling-screen-dim-when-you-enter-normal-mode)
* [Manual Installation](#manual-installation)

## Quick Installation

Run this command in Terminal:

```
bash <(curl -s https://raw.githubusercontent.com/dbalatero/VimMode.spoon/master/bin/installer)
```

then *read the post-install info* printed at the end and follow the instructions.

* If you prefer, follow the [Manual Instructions](#manual-instructions) instead.
* If you don't trust the script, please [audit it](https://github.com/dbalatero/VimMode.spoon/blob/master/bin/installer). It should be pretty straight-forward to read, and doesn't require root/sudo.
* It is safe to run this script multiple times.
* It will not break your existing Hammerspoon setup if you have one.
* It is progressive - it only sets up what is missing.

## Usage

Once installed:

* To enter normal mode, hit whichever key you bind to it (see below for key bind instructions)
* To exit normal mode, press `i` and you're back to a normal OS X input.

## Staying up to date

To update the plugin, run:

```
cd ~/.hammerspoon/Spoons/VimMode.spoon && git pull
```

## Current Support

### Flavors of VimMode.

There are two flavors of Vim mode that we try to enable using feature detection.

#### Advanced Mode

Advanced mode gets turned on when we detect the accessibility features we need
to make it work.  If the field you are focused in:

* Supports the OS X accessibility API
* Is not a rich field with images, embeds, etc
* Is not a `contentEditable` rich field in the web browser, I'm not touching that with a 10-foot pole
* Is not one of these applications that don't completely implement the Accessibility API:
  * Slack.app (Electron)
  * See [this file](https://github.com/dbalatero/VimMode.spoon/blob/ddce96de8f0edd0f9285e66fc76b4bdcc74916b4/lib/accessibility_buffer.lua#L9-L11) for reasons why these apps are broken and disabled out of the box.

In advanced mode, we actually can read in the value of the focused field and
modify cursor position/selection with theoretical perfect accuracy. In this
mode, I strive to make sure all Vim motions are as accurate as the editor. I'm
sure they are not, though, and would appreciate bug reports!

#### Fallback mode

In fallback mode, we just map Vim motions/operators to built-in text keyboard
shortcuts in OS X, and fire them blindly. This works pretty well, and is how
the original version of this plugin worked. There is some behavior that doesn't
match Vim however, which we cannot emulate without having the context that
Advanced Mode gives.

### Motions

- [x] `A` - jump to end of line
- [x] `G` - jump to last line of input
- [x] `I` - jump to beginning of line
- [x] `0` - beginning of line
- [x] `$` - end of line
- [ ] `f<char>`
- [ ] `F<char>`
- [ ] `t<char>`
- [ ] `T<char>`
- [ ] `aw` - a word
- [x] `b` - back by word
- [ ] `B` - back by big word (`:h WORD`)
- [x] `e` - fwd to end of word
- [ ] `E` - fwd to end of big word (`:h WORD`)
- [x] `gg` - top of buffer
- [x] `hjkl` - arrow keys
- [x] `w` fwd by word
- [x] `W` fwd by big word (`:h WORD`)
- [ ] `iw` - in word
- [ ] `i'` - in single quotes
- [ ] `i(` - in parens
- [ ] `i{` - in braces
- [ ] `i<` - in angle brackets
- [ ] `i`` - in backticks
- [ ] `i"` - in double quotes

### Operators

- [x] `shift + c` - delete to end of line, exit normal mode
- [x] `shift + d` delete to end of line
- [x] `c` - delete and exit normal mode
- [x] `d` - delete
- [x] `cc` - delete line and enter insert mode
- [x] `dd` - delete line
- [x] `r<char>` to replace - currently broken
- [x] `x` to delete char under cursor

### Other

- [x] `i` to go back to insert mode
- [x] `o` - add new line below, exit normal mode
- [x] `shift + o` - add new line above, exit normal mode
- [x] `p` to paste
- [x] `s` to delete under cursor, exit normal mode
- [x] `^r` to redo
- [x] `u` to undo
- [x] `y` to yank to clipboard
- [x] `/` to trigger `cmd+f` search (when `cmd+f` is supported in app)
- [x] visual mode with `v`
- [ ] support prefixing commands with numbers to repeat them (e.g. `2dw`)
- [ ] `^d` - page down
- [ ] `^u` - page down

## Configuration

Here are all the configuration options available for you. Add/edit your config
in ~/.hammerspoon/init.lua`.

### Binding jk to enter normal mode

```lua
vim = hs.loadSpoon('VimMode')

vim:enterWithSequence('jk')
```

This sequence only watches for simple characters - it can't handle uppercase
(`enterWithSequence('JK')`) or any other modifier keys (ctrl, shift). This is
meant to handle the popularity of people binding `jj`, `jk`, or `kj` to
entering normal mode in Vim.

The sequence also times out - if you type a `j` and wait < 1sec, it will type
the `j` for you.

If you have a sequence of `jk` and you go to type `ja` it will immediately
pass through the `ja` keys without any latency either. I wanted this to work
close to `inoremap jk <esc>`.

### Binding a single keystroke to enter normal mode

```lua
-- Basic key binding to ctrl+;
-- You can choose any key binding you want here, see:
--   https://www.hammerspoon.org/docs/hs.hotkey.html#bind

vim:bindHotKeys({ enter = {{'ctrl'}, ';'} })
```

### Disabling vim mode for certain apps

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

### Disabling the floating alert when you enter Vim mode(s)

```
vim = hs.loadSpoon('VimMode')
vim:shouldShowAlertInNormalMode(false)
```

### Enabling screen dim when you enter normal mode

This turns on a Flux-style dim when you enter normal mode.

```
vim = hs.loadSpoon('VimMode')
vim:shouldDimScreenInNormalMode(true)
```

## Manual Installation

Install [Hammerspoon](http://www.hammerspoon.org/go/)

Next, run this in your Terminal:

```
mkdir -p ~/.hammerspoon/Spoons
git clone https://github.com/dbalatero/VimMode.spoon \
  ~/.hammerspoon/Spoons/VimMode.spoon
```

Modify your `~/.hammerspoon/init.lua` file to contain the following:

```lua
local VimMode = hs.loadSpoon('VimMode')
local vim = VimMode:new()

vim
  :disableForApp('Code')
  :disableForApp('MacVim')
  :disableForApp('zoom.us')
  :enterWithSequence('jk')
```
