[![Travis](https://img.shields.io/travis/Airblader/i3.svg)](https://travis-ci.org/Airblader/i3)
[![Issues](https://img.shields.io/github/issues/Airblader/i3.svg)](https://github.com/Airblader/i3/issues)
[![Forks](https://img.shields.io/github/forks/Airblader/i3.svg)](https://github.com/Airblader/i3/network)
[![Stars](https://img.shields.io/github/stars/Airblader/i3.svg)](https://github.com/Airblader/i3/stargazers)

# i3 - Unofficial Fork

This is a fork of [i3wm](http://www.i3wm.org), a tiling window manager for Linux. It includes a few additional features which you can read up on below.

If you want to check out how you could use them, you could check out my [dotfiles repository](https://www.github.com/Airblader/dotfiles-manjaro).

This fork, much like i3 itself, maintains two branches: The `gaps` branch is the equivalent of i3's stable `master` branch while `gaps-next` contains `gaps` and i3's `next`.


# Installation

Please refer to the [wiki](https://github.com/Airblader/i3/wiki/Compiling-&-Installing) to see how i3-gaps can be installed and for which distributions there are packages available.

# Screenshot

![i3](http://i.imgur.com/y8sZE6o.jpg)


# New Features

## i3

### gaps

Note: Gaps will only work correctly if you disable window titlebars entirely. Unfortunately this is necessary due to the way i3 creates such bars on windows. You can disable them via `for_window [class="^.*"] border pixel 0` in your config. You can also use any non-zero value as long as you only use pixel-style borders.

Based on the patches provided by o4dev and jeanbroid, i3 supports gaps between containers. I extended those patches further to make changing the gaps size easier during runtime and also to expose more functionality for binding it to keys. Additionally, the gaps patch was fixed such that inner gaps (the gaps between adjacent containers) and outer gaps (gaps between the edge of the screen and a container) are the same. But I didn't stop there: these gaps are called "inner" gaps. This fork also allows setting "outer" gaps which inset all containers independently.

In your i3 config, you can set a global gap size as shown below. This is the default value that will be used for all workspaces:

```
gaps inner <px>
gaps outer <px>
```

Additionally, you can issue commands with the following syntax. This is useful, for example, to bind keys to changing the gap size:

```
gaps inner|outer current|all set|plus|minus <px>

# Examples
gaps inner all set 20
gaps outer current plus 5
```

Here are the individual parts explained:

* `inner|outer` specifies whether you want to modify inner gaps (gaps between adjacent containers) or outer gaps (gaps between the edge of a screen and a container).
* `current|all` determines whether you want to modify the setting for the current workspace only or for all workspaces.
* `set|plus|minus` allows you to either set a new, fixed value or make a relative change (in-/decrement).

Note that outer gaps are an *addition* to inner gaps, so `gaps outer all set 0` will eliminate outer gaps, but if inner gaps are set, there will still be gaps on the edge of the screen.

Additionally, gaps can be specified on a per-workspace level by using the syntax known from assigning a workspace to a certain output:

```
workspace <ws> gaps inner <px>
workspace <ws> gaps outer <px>
```

It is important that these commands are specified after the global default since they are meant to override it.
Note that multiple such assignments are allowed (and perhaps necessary).  The `ws` variable can either be a number or a name, so both of these are valid:

```
workspace 1 gaps inner 0
workspace "www" gaps inner 0
```

Here is one possible idea on how you can use this feature within your i3 config. Simply press `$mod+Shift+g` to enter the gaps mode. Then choose between `o` and `i` for modifying outer / inner gaps. In this mode, you can press one of `+` / `-` (in-/decrement for current workspace) or `0` (remove gaps for current workspace). If you also press `Shift` with these keys, the change will be global for all workspaces.

```
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

### Smart Gaps

If you want gaps to only be used if there is more than one container on the workspace, you can use

```
smart_gaps on
```

This will disable all gaps (outer and inner) on the workspace whenever only one container is on the current workspace.


### Smart Borders

Based on the patch from [i3-extras](https://github.com/ashinkarov/i3-extras), smart borders have been added in a configurable way. If activated, this patch will draw borders around a container only if it is not the only container in this workspace. It is disabled by default and can be activated with the command below. `on` will always activate it, while `no_gaps` will only activate it if the gap size to the edge of the screen is `0`.

```
smart_borders on|no_gaps
```
### Hide Edge Borders

An additional option `smart_no_gaps` is available for `hide_edge_borders`. This will hide all borders on a container if it is the only container in the worskpace *and* the gap size to the edge is `0`. Otherwise all borders will be drawn normally.

## i3bar

### Background & Color

i3bar now supports setting a background and border color for the individual blocks. Additionally, the border width for each of the four sides can be specified (where a width of `0` hides that border). Simply pass the following values via JSON to i3bar:

* `background` [color] sets the background color
* `border` [color] sets the border color
* `border_top`, `border_bottom`, `border_left`, `border_right` [int] width of the corresponding border (defaults to `1`)

Example:

```
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

```
bar {
        # height of the bar in pixels
        height 25
}
```

### Transparency / RGBA Colors

As an experimental feature, i3-gaps allows you to use RGBA colors for i3bar which allows for transparency. Please note that this has two implications:

* Due to technical constraints which can only be solved by a lot of effort, the background of tray icons will always be fully transparent, no matter what the background color of your i3bar is.
* This is experimental and bugs will only be fixed if doing so doesn't involve a lot of effort / big changes. The ability to easily stay up to date with upstream has priority.

In order to use this feature, run i3bar with the additional argument `-t`. This can be done in your i3 config as follows:

```
bar {
        i3bar_command i3bar -t
}
```
