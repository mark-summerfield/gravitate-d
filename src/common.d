// Copyright © 2020 Mark Summerfield. All rights reserved.
module qtrac.gravitate.common;

import std.string: splitLines;

enum APPNAME = "Gravitate";
enum VERSION = "v5.0.7";
static string[] ICON_XPM = splitLines(import("data/gravitate.dxpm"));
