// Copyright © 2020 Mark Summerfield. All rights reserved.

import common: APPNAME, ICON;
import gtk.Application: Application;
import gtk.ApplicationWindow: ApplicationWindow;
import gtk.Widget: Widget;

final class GameWindow: ApplicationWindow {
    this(Application application) {
        import gtk.Box : Box;
        import gtk.Button: Button;
        import gtkc.gtktypes : GtkOrientation;

        super(application);

        setTitle(APPNAME);
        setIconFromFile(ICON); // TODO embed

        // make widgets
        auto newButton = new Button("_New");
        auto aboutButton = new Button("_About");
        auto quitButton = new Button("_Quit");
        
        // make layout
        auto hbox = new Box(GtkOrientation.HORIZONTAL, 5);
        hbox.packStart(newButton, false, false, 5);
        hbox.packStart(aboutButton, false, false, 5);
        hbox.packEnd(quitButton, false, false, 5);
        add(hbox);

        // make bindings
        newButton.addOnClicked(delegate void(Button) { onNew(); });
        aboutButton.addOnClicked(delegate void(Button) { onAbout(); });
        quitButton.addOnClicked(delegate void(Button) { close(); });
        addOnDestroy(&onQuit);

        setSizeRequest(400, 400); // TODO load size/pos
        showAll();
    }

    void onNew() {
        import std.stdio: writeln;

        writeln("onNew");
    }

    void onAbout() {
        import aboutbox: about;

        about(this);
    }

    void onQuit(Widget) {
        import std.stdio: writeln;

        writeln("onQuit: save size/pos");

        destroy();
    }
}
