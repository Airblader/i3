i3 - Unofficial Fork
=====================

This is a fork of [i3wm](http://www.i3wm.org), a tiling window manager for Linux. It is based on two patches provided by

* https://github.com/jeanbroid/i3
* https://github.com/o4dev/i3

to allow for configurable gaps between containers in i3. However, I've also included patches on my own which are listed below. If you want
to check out how you could use them, you could check out my [dotfiles repository](https://www.github.com/Airblader/dotfiles).

As a general note, the `gaps` branch currently has i3 4.8 merged into it, while `gaps-next` ie the equivalent of `i3/next` with my patches.


Installation
============

First, clone the repository and switch into that folder. From there, installing (and updating) i3 is as easy as `make && sudo make install`. The next time you log in, simply select i3 as the desktop environment in your login manager. If you don't use one, start i3 from your `.xinitrc` or similar (in this case, I'm sure you know what to do – if not, google it).

When first compiling i3, you need to install a few dependencies. The following is a list of packages needed when compiling the `gaps` branch on a fresh installation of Ubuntu 14.04:


````
apt-get install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev \
  libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev
```

To compile `gaps-next`, you'll need the following as well:

````
apt-get install libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev
```

This may vary for other distributions. If you have trouble compiling it, just open an issue to let me know.


Screenshot
==========

![i3](http://i.imgur.com/ec7GqYB.png)


New Features
============

gaps
----

Based on the patches provided by o4dev and jeanbroid, i3 supports gaps between containers. I extended those patches further to make changing the gaps size easier during runtime and also to expose more functionality for binding it to keys.

In your i3 config, you can set a global gap size as shown below. This is the default value that will be used for all workspaces:

````
gap_size <px>
```

Additionally, you can issue commands with the following syntax. This is useful, for example, to bind keys to changing the gap size:

````
gap_size [current] [plus|minus] <px>
```

So, for example, `gap_size 10` would simply set the size of the gaps to 10 pixels. On the other hand, `gap_size plus 5` would increase the current gap size without having to know how much it actually is. Note that `gap_size 0` is basically equivalent to not using the gaps patch at all. This is the default value.

Here is an exceprt from my i3 config that shows how this can be utilized. Press `$mod+Shift+g` to enter a special mode to modify the gap size. From there, you can press either `+`, `-` or `0` to increase / decrease the gap size or turn gaps off for the current workspace. If you hold `Shift` while doing this, it will modify the setting globally for all workspaces.

````
set $mode_gap_size Gaps: [+|-|0] for current workspace, Shift + [+|-|0] for all workspaces
mode "$mode_gap_size" {
        bindsym plus gap_size current plus 5
        bindsym minus gap_size current minus 5
        bindsym 0 gap_size current 0

        bindsym Shift+plus gap_size plus 5
        bindsym Shift+minus gap_size minus 5
        bindsym Shift+0 gap_size 0

        bindsym Return mode "default"
        bindsym Escape mode "default"
}

bindsym $mod+Shift+g mode "$mode_gap_size"
```


i3bar Background & Color
------------------------

i3bar now supports setting a background and border color for the individual blocks. Additionally, it can be specified which of the four sides should have a border. Simply pass the following values via JSON to i3bar:

* `background` [color] sets the background color
* `border` [color] sets the border color
* `border_top`, `border_bottom`, `border_left`, `border_right` [boolean] whether to draw a border on the specified side (defaults to `true`)

Example:

````
{ \
  "full_text": "example", \
  "color": "\#FFFFFF", \
  "background": "\#222222", \
  "border": "\#9FBC00", \
  "border_bottom": false \
}
```


Smart Borders
-------------

With the original patch from [i3-extras](https://github.com/ashinkarov/i3-extras), I've made the smart border feature configurable. If activated, this patch will draw borders around a container only if it is not the only container in this workspace. It is disabled by default and can be activated with

````
smart_borders on
```
