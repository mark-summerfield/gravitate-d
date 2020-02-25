# Gravitate

A SameGame/TileFall-like game written in D/GtkD.

## Windows

The file `gravitate-win64.zip` contains a 64-bit Windows binary and this
`README.md` file.
Just unzip it somewhere convenient and double-click `gravitate.exe` to run.

## Build

You will need a D compiler and the GtkD 3 library.

To get a D compiler (I use LDC) see: 
[dlang.org/download.html](https://dlang.org/download.html).

Once D is installed, install the Gtk runtime, then download and install
the GtkD library. For these, see:
[gtkd.org](https://gtkd.org/).

Make sure `dub` can find GtkD by running:

`dub add-path path/to/GtkD3`

Then, in the directory you've cloned or unpacked Gravitate, if using LDC
run:

`dub -brelease`

(For other compilers either just run `dub` or lookup how to do a release
build.)

Then, move the gravitate executable to somewhere convenient.

## License

GPL-3.0.

## Other Versions

For versions in Nim/NiGui, Java/AWT/Swing, Python/Tkinter,
Python/wxPython, and JavaScript see
[www.qtrac.eu/gravitate.html](http://www.qtrac.eu/gravitate.html).

## Notes

This is my first D/GtkD program -- in fact my first Gtk program.

This version sometimes doesn't refresh after a click or press of the
spacebar, in which case click or press again. I think this is due to me
not fully understanding Gtk timers.
