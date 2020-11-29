# 2020-11-29

* Added the `iw` "in word" text object motion
* Added the `i[`, `i<`, `i{`, `i'`, `i"`, and `i`` motions.
* Added `ctrl-u` and `ctrl-d` to page up/down half a visible screen

# 2020-11-04

* Fix offset calculations with UTF-8 characters like smart quotes.
* Add a beta feature for enabling a block cursor overlay in fields that support it in #65. Turn this on with `vim:enableBetaFeature('block_cursor_overlay')`

# 2020-10-15

* Fix the library to work on the new Lua 5.4 version of Hammerspoon. Previous releases before Hammerspoon 0.9.79 will not work anymore.

# 2020-09-06

* Fix #54 where the overlay doesn't sit above the Safari location bar

# 2020-08-30

* Allow advanced mode to work in `AXComboBox` fields

# 2020-08-29

* Passthru the main Vim normal mode keys when focused in a disabled app
* Update the key sequence to have a default timeout of 140ms to accommodate `jj` users
* Make key sequence timeout optionally configurable

There is no changelog prior to this date :(
