// Copyright © 2020 Mark Summerfield. All rights reserved.

import gamewindow: GameWindow;

void about(GameWindow parent) {
    import common: APPNAME, VERSION, ICON;
    import std.compiler: compiler = name, version_major, version_minor;
    import std.conv: to;
    import std.datetime.systime: Clock;
    import std.format: format;
    import std.system: os;
    import gdk.Pixbuf: Pixbuf;
    import gtk.AboutDialog: AboutDialog;
    import gtk.Version: Version;

    auto thisYear = Clock.currTime.year;
    auto year = thisYear == 2020 ? thisYear.to!string
                                 : format("2020-%d", thisYear - 2000);
    auto about = new AboutDialog;
    scope(exit) about.destroy;
    about.setProgramName(APPNAME);
    about.setVersion(VERSION);
    auto icon = new Pixbuf(ICON); // TODO embed
    about.setLogo(icon);
    about.setAuthors(["Mark Summerfield"]);
    about.setComments(
        "A SameGame/TileFall-like game.\n\n" ~ format(
        "Written in D with GtkD %s.%s using %s %s.%s on %s.\n",
        Version.getMajorVersion, Version.getMinorVersion,
        compiler, version_major, version_minor, os));
    about.setCopyright(format(
        "Copyright © %s Mark Summerfield. All rights reserved.", year));
    about.setLicense("Free Open Source Software: Apache-2.0 License");
    about.setWebsite("https://www.qtrac.eu/gravitate.html");
    about.setWebsiteLabel("www.qtrac.eu/gravitate.html");
    about.setTransientFor(parent);
    about.run;
}
