---
title: Migrating from iTerm2 to Ghostty
description: After over a decade with iTerm2, I evaluated modern terminal emulators to fix Claude Code rendering issues and settled on Ghostty.
layout: post
category: Tools
tags:
  - Terminal
  - iTerm2
  - Ghostty
  - Claude Code
  - macOS
keywords:
  - Terminal Emulator
  - iTerm2
  - Ghostty
  - WezTerm
  - Kitty
  - Claude Code
  - macOS
---

I've been a happy [iTerm2](https://iterm2.com/) user for over a decade now. I know there's been terminal innovation out there over the years, but I haven't felt too compelled to switch - if it ain't broke and it's a good tool, why change? That said, I recently ran into some frustrations with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) occasionally doing some really weird line-wrapping stuff in iTerm2, and from what I can tell it really is Claude Code's fault due to the way it draws to the terminal. This was enough to push me to evaluate what else is out there.

Because I was pretty comfortable with how my iTerm2 setup works I came at this from wanting to generally replicate the feel for better or worse. I went through a list of fairly modern and popular terminal emulators that I've heard crop up over the years. I've tried some before like [Hyper](https://hyper.is/) and [Warp](https://www.warp.dev/) terminal that felt way too heavy from memory, and I haven't heard anyone sing their praises recently so maybe a flash in the pan sort of thing? Anyway, here's what I tried and why I rejected each one (I figured if I write it down, in a year or two I can come back here and remember WHY I didn't like something because I always forget). Aside from my comments below, they're all meant to be really loved and very performant terminal emulators that are GPU accelerated and all that jazz.

### [WezTerm](https://wezfurlong.org/wezterm/)

The nerdiest one of them all in terms of configuration. Most of these terminal emulators are all DIY config files now rather than a GUI like iTerm2. This was my runner up to the one I selected - I wasn't 100% happy with how the terminal tabs appeared but I didn't mind it in the end. However, there is currently an issue with Claude Code where if you resize the window you can't scroll to the bottom (most recent) part of your conversation with the agent. I'm not resizing my terminals all the time but I certainly did it just with normal use and ran into that issue. It's a known issue so maybe I'll come back in 6 months and see how it's going.

This terminal also wins the award for worst icon for a terminal.

### [Kitty](https://sw.kovidgoyal.net/kitty/)

This is the one I tried the least. It blocked me early on because I could NOT get the tabs in a spot where I was really happy with them. And with the closest way I could get the tabs to an okay spot I lost the ability to click and drag the window somewhere else on my screen via the titlebar, and that made me throw in the towel super quickly.

I don't think I'd look at Kitty again - its design choices might differ a bit from what I want. It aims to be the absolute bleeding fastest most performant lowest latency terminal around, likely for people that live in neovim all day every day perhaps?

### [Alacritty](https://alacritty.org/)

This one was initially on my radar but I had heard of poor Claude Code compatibility in it as well, so I didn't end up evaluating it.

### [Ghostty](https://ghostty.org/)

This is the one I settled on. I got it to a state reasonably quickly where I felt invested to spend a little bit longer fine tuning it and getting it the full way there. I pretty much got it looking close enough to iTerm2 that I can't really tell the difference side by side. My Claude Code issues have gone away completely and overall (from reading comparisons) it should be more performant and use less memory per tab than iTerm2 was using.

There was only one weird thing - if I had a lot of output and needed to scroll up I didn't actually have a scrollbar which was odd. The ability to have it has been merged in but it's not in the stable release so I had to switch to nightly releases, which has been perfectly fine. The nightly release currently has a different bug where whenever I want to open a new tab I ALWAYS want it to start in my home directory but instead it starts in the directory of the last tab you were on (unless you open a new window then it works as expected). That bug is not enough to put me off of it right now as it seems like something that'd be fixed soon - there is config to control it, the config just seems to be ignored currently.

### The Migration Process

For all of the terminals I used Claude to look at my iTerm2 config and write configs for the other terminals so I had a good starting point and iterated from there. This was a huge timesaver and I'd recommend doing the same if you're evaluating terminal emulators.

### Conclusion

So far I'm happy with Ghostty as a replacement to iTerm2. If WezTerm fixes the Claude Code issue they have with resize I'd consider going back and re-evaluating it. For now though, Ghostty gets the job done and I can use Claude Code without the weird rendering glitches that were driving me crazy.
