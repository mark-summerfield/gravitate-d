// Copyright © 2020 Mark Summerfield. All rights reserved.

import common: APPNAME, VERSION, ICON;
import gamewindow: GameWindow;

void about(GameWindow window) {
    import std.compiler: dname = name, D_major, version_major,
           version_minor;
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
    auto icon = new Pixbuf(ICON); // TODO embed
    auto dialog = new AboutDialog();
    dialog.setProgramName(APPNAME);
    dialog.setVersion(VERSION);
    dialog.setLogo(icon);
    dialog.setAuthors(["Mark Summerfield"]);
    dialog.setComments(
        "A game similar to TileFall or the SameGame.\n\n" ~
        format("Written in D %s / GtkD %s.%s.%s using %s %s.%s on " ~
                "%s-bit %s.\n", D_major, Version.getMajorVersion(),
                Version.getMinorVersion(), Version.getMicroVersion(),
                dname, version_major, version_minor, (size_t.sizeof * 8),
                os));
    dialog.setCopyright(
        format("Copyright © %s Mark Summerfield. All rights reserved.",
                year));
    dialog.setLicense("Free Open Source Software: Apache-2.0 License");
    dialog.setWebsite("https://www.qtrac.eu/gravitate.html");
    dialog.setWebsiteLabel("www.qtrac.eu/gravitate.html");
    dialog.setTransientFor(window);
    dialog.run();
    scope(exit) dialog.destroy();
}
