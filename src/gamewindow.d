#!/usr/bin/env dub
// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.Application: Application;
import gtk.ApplicationWindow: ApplicationWindow;
import gtk.Widget: Widget;

final class GameWindow: ApplicationWindow {
    this(Application application) {
        import gtk.Button: Button;

        super(application);

        setTitle("Gravitate");
        // make widgets
        auto newButton = new Button("New");
        
        // make layout
        add(newButton);

        // make bindings
        addOnDestroy(&quit);
        newButton.addOnClicked(delegate void(Button) { onNew(); });

        setSizeRequest(400, 400); // TODO load/save last size/pos
        showAll();
    }

    void onNew() {
        import std.stdio: writeln;

        writeln("onNew");
    }

    void quit(Widget) {
        import gtk.Main: Main;

        Main.quit();
    }
}
