# Welcome!

## What is Triton?

I was inspired by DHH's [Omarchy](https://omarchy.org/) early versions, pre-ISO, when it was a collection of Bash scripts.

I started with [Archon](https://github.com/rmay/archon) using [Arch](https://archlinux.org/) and [Window Maker](https://www.windowmaker.org/).

After experimenting with that setup, I decided the concept should work as well for [FreeBSD](https://www.freebsd.org/). Lessons learned are applied here.

This is not for the casual computer user, this is for people that like computers as tinkering machines but still want to get stuff done.

It comes preinstalled with shells, a few development tools, Waterfox, LibreOffice, basically everything needed to get started in a productive environment.

It's a mix of TUI and GUI elements, wrangled together to present a more cohesive whole than what comes out-of-the-box.

If you want something much more polished, check out DHH's [Omakub](https://omakub.org/) or [Omarchy](https://omarchy.org/). Both are stellar projects and I promise you won't hurt my feelings if you choose one or the other.

Still with me? Let's do this.

## Brief install instructions for the busy developer

Install FreeBSD according to the [official documentation](https://docs.freebsd.org/en/books/handbook/bsdinstall/).

Installing FreeBSD itself is beyond the scope of this documentation.

After rebooting into your fresh FreeBSD install, run these commands.

```sh
$ fetch https://rmay.github.io/triton/triton-install
$ chmod +x triton-install
$ su
# ./triton-install
```

You'll be prompted for the target user name, and later the `git user` and `git user email`.

This will set up the base system with all the default settings. Once that's done, the system will reboot and present you with a login screen. Log in again with your FreeBSD user, and welcome to the cutting edge of retro-future 90s!

I've been mostly developing on a VM, but I have tried it on real hardware and am slowly making it my primary non-work development environment. Just one more shell script, bro.

## What's in the box?

Here's a partial list of what it comes with out-of-the-box:

* Window Maker and some extras.
* A curated Window Maker menu.
* Window Maker set up for 4 workspaces. You access them quickly by `Super+<n>` or by using the mouse wheel on the root window. The clip in the upper right corner shows the current workspace and lets you move through them by clicking the arrows. You can move a window to a workspace with `Super+Ctrl+<n>`.
* Two terminals: xterm, and urxvt. The default terminal is currently xterm.
* A browser: Waterfox.
* Two file managers: Thunar, and Ranger in a terminal.
* Development tools: Neovim using LazyVim for the defaults, Emacs, Geany, and Zed.
* LibreOffice.
* Two PDF viewers: Evince and xpdf.
* Logseq.
* Nextcloud.
* Gimp.
* VLC.
* mpv.
* Rofi and dmenu.
* Go and Ruby preinstalled.

The `triton` TUI lets you:

* Set the default terminal.
* Change the curated theme.
* Install additional programming languages: Java, SBCL with Quicklisp, Squeak Smalltalk, Erlang and Elixir, Python. (Clang is already installed. I'm using [mise](https://mise.jdx.dev/) to manage Ruby and Go. Erlang and Elixir are managed with [asdf](https://asdf-vm.com/).)

In addition to the default keyboard shortcuts offered by Window Maker, I'm using xbindkeys.

A few shortcuts:

* `Super+Return` starts the default terminal.
* `Super+Return+Shift` starts xterm, just in case.
* `Super+~` starts dmenu.
* `Super+Space` starts rofi.

See [Shortcuts](shortcuts.md) for more details.


# But, why?

I want a stable, repeatable experience in FreeBSD. I've tried a few BSDs over the years, but nothing really gelled. I've liked things from all sorts of places, but never in a complete package. And while not perfect, I have a fondness for the 90s computer aesthetic. And I wanted to just do a thing.

* FreeBSD for the reliability and one of the best documented OSes.
* X11 because it is still a better system than Wayland. Not flashier, but battle-hardened and proven.
* Window Maker because the aesthetic is solid, it's lightweight, and I like it, despite being so old.
* C/C++ to compile all the things.
* Ruby because it's a great language.
* Go because it's the best get stuff done language I've found.
* Squeak Smalltalk because the concepts are from a future we could have had.
* Java because it runs everything.
* SBCL because if you don't have some half-started Common Lisp app buried somewhere are you really trying?
* Neovim because it's hip.
* Emacs because it's not.
* Zed because GUI editors aren't ontologically evil.
* LazyGit because it's really slick and easy to use.


No surveillance, no subscriptions, no corporate dependencies. Your computer, your data, your environment.

