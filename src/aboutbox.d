// Copyright © 2020 Mark Summerfield. All rights reserved.

import gamewindow: GameWindow;

void about(GameWindow window) {
    import common: APPNAME, VERSION, ICON;
    import std.compiler: dname = name, version_major, version_minor;
    import std.conv: to;
    import std.datetime.systime: Clock;
    import std.format: format;
    import std.system: os;
    import gdk.Pixbuf: Pixbuf;
    import gtk.AboutDialog: AboutDialog;
    import gtk.Version: Version;

    auto thisYear = Clock.currTime().year;
    auto year = thisYear == 2020 ? thisYear.to!string
                                    : format("2020-%d", thisYear - 2000);
    auto dialog = new AboutDialog();
    scope(exit) dialog.destroy();
    dialog.setProgramName(APPNAME);
    dialog.setVersion(VERSION);
    auto icon = new Pixbuf(ICON); // TODO embed or SVG
    dialog.setLogo(icon);
    dialog.setAuthors(["Mark Summerfield"]);
    dialog.setComments(
        "A SameGame/TileFall-like game.\n\n" ~
        format("Written in D with GtkD %s.%s using %s %s.%s on %s.\n",
               Version.getMajorVersion(), Version.getMinorVersion(), dname,
               version_major, version_minor, os));
    dialog.setCopyright(
        format("Copyright © %s Mark Summerfield. All rights reserved.",
                year));
    dialog.setLicense("Free Open Source Software: Apache-2.0 License");
    dialog.setWebsite("https://www.qtrac.eu/gravitate.html");
    dialog.setWebsiteLabel("www.qtrac.eu/gravitate.html");
    dialog.setTransientFor(window);
    dialog.run();
}
