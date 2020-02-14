#!/usr/bin/env dub
// Copyright © 2020 Mark Summerfield. All rights reserved.
import gdk.Event;
import gtk.Button;
import gtk.Main;
import gtk.MainWindow;
import gtk.Widget;
import std.stdio: writeln;

final class GameWindow : MainWindow {
    this() {
        super("Gravitate");
        // TODO
        auto newButton = new Button("New");
        newButton.addOnClicked(delegate void(Button b) { onNew(); });
        
        add(newButton);

        addOnDestroy(&quit);
        showAll();
    }

    void onNew() {
        writeln("onNew");
    }

    void quit(Widget widget) {
        Main.quit();
    }
}
