#!/usr/bin/env dub
// Copyright © 2020 Mark Summerfield. All rights reserved.
import gamewindow: GameWindow;
import gio.Application: GioApplication = Application;
import gtk.Application: Application;
import gtk.ApplicationWindow: GApplicationFlags;

int main(string[] args) {
    auto application = new Application("eu.qtrac.gravitate",
                                       GApplicationFlags.FLAGS_NONE);
    application.addOnActivate(delegate void(GioApplication) {
        new GameWindow(application);
    });
    return application.run(args);
}
