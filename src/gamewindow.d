#!/usr/bin/env dub
// Copyright © 2020 Mark Summerfield. All rights reserved.
import gtk.Application: Application;
import gtk.ApplicationWindow: ApplicationWindow;
import gdk.Event;
import gtk.Button;
import gtk.Main;
import gtk.MainWindow;
import gtk.Widget;
import std.stdio: writeln;

final class GameWindow: ApplicationWindow {
    this(Application application) {
        super(application);
        setTitle("Gravitate");
        // make widgets
        auto newButton = new Button("New");
        newButton.addOnClicked(delegate void(Button) { onNew(); });
        
        // make layout
        add(newButton);

        // make bindings
        addOnDestroy(&quit);
        setSizeRequest(400, 400); // TODO load/save last size/pos
        showAll();
    }

    void onNew() {
        writeln("onNew");
    }

    void quit(Widget) {
        Main.quit();
    }
}
