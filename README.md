# i3 - Unofficial Fork

This is a fork of [i3wm](http://www.i3wm.org), a tiling window manager for Linux. It includes a few additional features which you can read up on below.

If you want to check out how you could use them, you could check out my [dotfiles repository](https://www.github.com/Airblader/dotfiles).

This fork, much like i3 itself, maintains two branches: The `gaps` branch is the equivalent of i3's stable `master` branch while `gaps-next` contains `gaps` and i3's `next`.


# Installation

First, clone the repository and switch into that folder. From there, installing (and updating) i3 is as easy as `make && sudo make install`. The next time you log in, simply select i3 as the desktop environment in your login manager. If you don't use one, start i3 from your `.xinitrc` or similar (in this case, I'm sure you know what to do – if not, google it).

When first compiling i3, you need to install a few dependencies. The following is a list of packages needed when compiling the `gaps` branch on a fresh installation of Ubuntu 14.04. The package names for other distros will be different, but if you use, e.g., Arch, you probably know how to figure them out anyway.


````
apt-get install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev \
  libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev
```

To compile `gaps-next`, you'll need the following as well:

````
apt-get install libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev
```

This may vary for other distributions. If you have trouble compiling it, just open an issue to let me know.

## Arch Linux

[i3-gaps](https://aur.archlinux.org/packages/i3-gaps/) is available on the AUR.

# Updating

You can update by simply switching into the directory of the repository and executing `git pull`. Then rebuild and install via `make && sudo make install`.

Please note that I do not care too much for backwards compatibility. At the time of installation, this readme will always be up to date. When I change something, I will update the readme as well. Before pulling, please check if something has changed and adapt your config / scripts accordingly. If there are any questions on how to adapt something, please feel free to contact me by opening an issue.

# Screenshot

![i3](http://i.imgur.com/Jw2kom9.png)


# New Features

## i3

### gaps

Based on the patches provided by o4dev and jeanbroid, i3 supports gaps between containers. I extended those patches further to make changing the gaps size easier during runtime and also to expose more functionality for binding it to keys. Additionally, the gaps patch was fixed such that the gaps between containers and the gaps between containers and the edge of the screen are the same. But I didn't stop there: these gaps are called "inner" gaps. This fork also allows setting "outer" gaps which inset all containers independently.

In your i3 config, you can set a global gap size as shown below. This is the default value that will be used for all workspaces:

````
gaps inner <px>
gaps outer <px>
```

Additionally, you can issue commands with the following syntax. This is useful, for example, to bind keys to changing the gap size:

````
gaps inner|outer current|all set|plus|minus <px>

# Examples
gaps inner all set 20
gaps outer current plus 5
```

Here are the individual parts explained:

* `inner|outer` specifies whether you want to modify inner gaps (gaps between adjacent containers) or outer gaps (gaps between the edge of a screen and a container).
* `current|all` determined whether you want to modify the setting for the current workspace only or for all workspaces.
* `set|plus|minus` allows you to either set a new, fixed value or make a relative change (in-/decrement).

Note that outer gaps are an *addition* to inner gaps, so `gaps outer all set 0` will elinminate outer gaps, but if inner gaps are set, there will still be gaps on the edge of the screen.

Here is an excerpt from my i3 config that shows how this can be utilized. Press `$mod+Shift+g` to enter a special mode to modify the gap size. From there, you can press either `+`, `-` or `0` to increase / decrease the gap size or turn gaps off for the current workspace. If you hold `Shift` while doing this, it will modify the setting globally for all workspaces.

Here is one possible idea on how you can use this feature within your i3 config. Simply press `$mod+Shift+g` to enter the gaps mode. Then choose between `o` and `i` for modifying outer / inner gaps. In this mode, you can press one of `+` / `-` (in-/decrement for current workspace) or `0` (remove gaps for current workspace). If you also press `Shift` with these keys, the change will be global for all workspaces.

````
set $mode_gaps Gaps: (o) outer, (i) inner
set $mode_gaps_outer Outer Gaps: +|-|0 (local), Shift + +|-|0 (global)
set $mode_gaps_inner Inner Gaps: +|-|0 (local), Shift + +|-|0 (global)
bindsym $mod+Shift+g mode "$mode_gaps"

mode "$mode_gaps" {
        bindsym o      mode "$mode_gaps_outer"
        bindsym i      mode "$mode_gaps_inner"
        bindsym Return mode "default"
        bindsym Escape mode "default"
}

mode "$mode_gaps_inner" {
        bindsym plus  gaps inner current plus 5
        bindsym minus gaps inner current minus 5
        bindsym 0     gaps inner current set 0

        bindsym Shift+plus  gaps inner all plus 5
        bindsym Shift+minus gaps inner all minus 5
        bindsym Shift+0     gaps inner all set 0

        bindsym Return mode "default"
        bindsym Escape mode "default"
}
mode "$mode_gaps_outer" {
        bindsym plus  gaps outer current plus 5
        bindsym minus gaps outer current minus 5
        bindsym 0     gaps outer current set 0

        bindsym Shift+plus  gaps outer all plus 5
        bindsym Shift+minus gaps outer all minus 5
        bindsym Shift+0     gaps outer all set 0

        bindsym Return mode "default"
        bindsym Escape mode "default"
}
```


### Smart Borders

With the original patch from [i3-extras](https://github.com/ashinkarov/i3-extras), I've made the smart border feature configurable. If activated, this patch will draw borders around a container only if it is not the only container in this workspace. It is disabled by default and can be activated with

````
smart_borders on
```


## i3bar

### Background & Color

i3bar now supports setting a background and border color for the individual blocks. Additionally, the border width for each of the four sides can be specified (where a width of `0` hides that border). Simply pass the following values via JSON to i3bar:

* `background` [color] sets the background color
* `border` [color] sets the border color
* `border_top`, `border_bottom`, `border_left`, `border_right` [int] width of the corresponding border (defaults to `1`)

Example:

````
{ \
  "full_text": "example", \
  "color": "\#FFFFFF", \
  "background": "\#222222", \
  "border": "\#9FBC00", \
  "border_bottom": 0 \
}
```

### Bar Height

The height of any bar can be configured to have an arbitrary value. This is especially useful if you plan on using top/bottom borders on status blocks to make the bar taller. If the height is not set, it will be calculated as normal. To set it, use the `height` directive in the `bar` configuration block:

````
bar {
        # height of the bar in pixels
        height 25
}
```
