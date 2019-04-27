[![Travis](https://img.shields.io/travis/Airblader/i3.svg)](https://travis-ci.org/Airblader/i3)
[![Issues](https://img.shields.io/github/issues/Airblader/i3.svg)](https://github.com/Airblader/i3/issues)
[![Forks](https://img.shields.io/github/forks/Airblader/i3.svg)](https://github.com/Airblader/i3/network)
[![Stars](https://img.shields.io/github/stars/Airblader/i3.svg)](https://github.com/Airblader/i3/stargazers)

# i3-gaps

## What is i3-gaps?

i3-gaps is a fork of [i3wm](https://www.i3wm.org), a tiling window manager for X11. It is kept up to date with upstream, adding a few additional features such as gaps between windows (see below for a complete list).

![i3](https://i.imgur.com/KC7GL4D.png)

## How do I install i3-gaps?

Please refer to the [wiki](https://github.com/Airblader/i3/wiki).

## Where can I get help?

For bug reports or feature requests regarding i3-gaps specifically, open an issue on [GitHub](https://www.github.com/Airblader/i3). If your issue is with core i3 functionality, please report it [upstream](https://www.github.com/i3/i3).

For support & all other kinds of questions, you can ask your question on the official [subreddit /r/i3wm](https://www.reddit.com/r/i3wm).

# Features

## i3

### gaps

*Note:* In order to use gaps you need to disable window titlebars. This can be done by adding the following line to your config.

```
# You can also use any non-zero value if you'd like to have a border
for_window [class=".*"] border pixel 0
```

Gaps are the namesake feature of i3-gaps and add spacing between windows/containers. Gaps come in two flavors, inner and outer gaps wherein inner gaps are those between two adjacent containers (or a container and an edge) and outer gaps are an additional spacing along the screen edges. Gaps can be configured in your config either globally or per workspace, and can additionally be changed during runtime using commands (e.g., through `i3-msg`).

*Note:* Outer gaps are added to the inner gaps, i.e., the gaps between a screen edge and a container will be the sum of outer and inner gaps.

#### Configuration

You can define gaps either globally or per workspace using the following syntax. Note that the gaps configurations should be ordered from least specific to most specific as some directives can overwrite others.

```
gaps [inner|outer|horizontal|vertical|top|left|bottom|right] <px>
workspace <ws> gaps [inner|outer|horizontal|vertical|top|left|bottom|right] <px>
```

The `inner` and `outer` keywords are as explained above. With `top`, `left`, `bottom` and `right` you can specify outer gaps on specific sides, and `horizontal` and `vertical` are shortcuts for the respective sides. `<px>` stands for a numeric value in pixels and `<ws>` for either a workspace number or a workspace name.

#### Commands

Gaps can be modified at runtime with the following command syntax:

```
gaps inner|outer|horizontal|vertical|top|right|bottom|left current|all set|plus|minus|toggle <px>

# Examples
gaps inner all set 20
gaps outer current plus 5
gaps horizontal current plus 40
gaps outer current toggle 60
```

With `current` or `all` you can change gaps either for only the currently focused or all currently existing workspaces (note that this does not affect the global configuration itself).

You can find an example configuration in the [wiki](https://github.com/Airblader/i3/wiki/Example-Configuration).

### Smart Gaps

Gaps can be automatically turned on/off on a workspace in certain scenarios using the following config directives:

```
# Only enable gaps on a workspace when there is at least one container
smart_gaps on

# Only enable outer gaps when there is exactly one container
smart_gaps inverse_outer
```

### Smart Borders

Smart borders will draw borders on windows only if there is more than one window in a workspace. This feature can also be enabled only if the gap size between window and screen edge is `0`.

```
# Activate smart borders (always)
smart_borders on

# Activate smart borders (only when there are effectively no gaps)
smart_borders no_gaps
```

### Smart Edge Borders

This extends i3's `hide_edge_borders` with a new option. When set, edge-specific borders of a container will be hidden if it's the only container on the workspace and the gaps to the screen edge is `0`.

## i3bar

### Bar Height

The height of an i3bar instance can be specified explicitly by defining the `height` key in the bar configuration. If not set, the height will be calculated automatically depending on the font size.

```
bar {
    # Height in pixels
    height 25
}
```

### Borders

You can define a border width of each block for each individual side by sending the `border_top`, `border_left`, `border_bottom` and `border_right` keys in the i3bar JSON protocol. Each value, if absent, defaults to `1`, and a value of `0` hides the border for the specified side.

### Transparency and RGBA Colors

By starting i3bar with the `-t` flag, RGBA color mode will be activated. This allows the use of colors with an additional alpha channel. Please note that this has two major implications:

* Due to technical constraints the background of tray icons will always be fully transparent.
* We consider this feature unstable in the sense that issues will only be fixed if they do not require major changes as we prioritize the ability to stay up to date with upstream.

To start i3bar with the `-t` flag, adapt your bar configuration:

```
bar {
        i3bar_command i3bar -t
}
```

You can now use RGBA colors, e.g. `#FFFFFF99` where the last two digits represent the alpha channel.
