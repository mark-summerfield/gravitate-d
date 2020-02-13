#!/usr/bin/env dub
// Copyright © 2020 Mark Summerfield. All rights reserved.
import gtk.Main;
import std.stdio;

void main(string[] args) {
    import gtk.MainWindow: MainWindow;

	Main.init(args);
	MainWindow mainWindow = new MainWindow("Gravitate");
	mainWindow.addOnDestroy(delegate void(Widget) { Main.quit(); } );
	mainWindow.showAll();
	Main.run();
}
