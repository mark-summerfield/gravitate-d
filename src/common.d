// Copyright © 2020 Mark Summerfield. All rights reserved.

import std.typecons: Tuple;

alias Color = Tuple!(double, "red", double, "green", double, "blue");

enum APPNAME = "Gravitate";
enum VERSION = "v5.0.0";
enum ICON = "images/gravitate64.png"; // TODO embed or SVG
enum ACTIVE_BG_COLOR = Color(1, 0.9961, 0.8784);
