#!/usr/bin/env dub
// Copyright © 2020 Mark Summerfield. All rights reserved.
import gtk.Main: Main;
import gtk.MainWindow: MainWindow;
import gtk.Widget: Widget;
import std.stdio;

void main(string[] args) {
    Main.init(args);
    auto game = new GameWindow();
    Main.run();
}

private class GameWindow : MainWindow {
    this() {
        super("Gravitate");
        // TODO
        addOnDestroy(&quit);
        showAll();
    }

    void quit(Widget widget) {
        Main.quit();
    }
}
