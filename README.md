i3 - Unofficial Fork
=====================

This fork uses the patches provided in

* https://github.com/jeanbroid/i3
* https://github.com/o4dev/i3

to allow for configurable gaps between containers in i3. On top of that, the following changes were made:

* Merged i3 4.8 to get to the latest release
* Introduced a patch to allow background and border settings in i3bar blocks via JSON

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
````
