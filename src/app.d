#!/usr/bin/env dub
// Copyright © 2020 Mark Summerfield. All rights reserved.
import gamewindow: GameWindow;
import gtk.Main;

void main(string[] args) {
    Main.init(args);
    auto game = new GameWindow();
    Main.run();
}
