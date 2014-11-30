i3 - Unofficial Fork
=====================

This fork uses the patches provided in

* https://github.com/jeanbroid/i3
* https://github.com/o4dev/i3

to allow for configurable gaps between containers in i3. On top of that, the following changes were made:

* Merged i3 4.8 to get to the latest release
* Introduced a patch to allow background and border settings in i3bar blocks via JSON

Installation
------------

Simply clone the repository, switch into the the directory and execute `make && sudo make install`. The next time you log in, you can switch i3 in your login manager environment.

i3 has a few dependencies. Here is a list of packages that I needed to install on a clean Ubuntu 14.10 installation to build the project:

````
apt-get install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev \
  libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev
```

Status Block Background & Color
-------------------------------

This fork supports setting a background and border color for i3bar blocks as well as specifying on which sides these borders should be drawn. The following keys can be passed in via JSON:

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

Screenshot
----------

![i3](http://i.imgur.com/W2iMHHW.png)
