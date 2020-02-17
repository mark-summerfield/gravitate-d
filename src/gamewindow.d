// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.ApplicationWindow: ApplicationWindow;

final class GameWindow: ApplicationWindow {
    import board: Board;
    import gtk.Application: Application;
    import gtk.Button: Button;
    import gtk.Label: Label;
    import gtk.Widget: Widget;

    private Button newButton;
    private Button optionsButton;
    private Button helpButton;
    private Button aboutButton;
    private Button quitButton;
    private Board board;
    private Label statusLabel;

    this(Application application) {
        import common: APPNAME, ICON;

        super(application);
        setTitle(APPNAME);
        setIconFromFile(ICON); // TODO embed
        makeWidgets();
        makeLayout();
        makeBindings();

        int width = 400;
        int height = 400;
        setSizeRequest(width, height);
        getSize(width, height);
import std.stdio: writefln; writefln("this: load size/pos/hiscore %sx%s",
width, height);
        board.setSizeRequest(width, height - 40);

        showAll();
    }

    void makeWidgets() {
        import gtkc.gtktypes : StockID;

        newButton = new Button(StockID.NEW);
        // TODO keep the preferences icon but change the text to "_Options"
        optionsButton = new Button(StockID.PREFERENCES);
        helpButton = new Button(StockID.HELP);
        aboutButton = new Button(StockID.ABOUT);
        quitButton = new Button(StockID.QUIT);
        // TODO get the board size based on window size
        board = new Board();
        statusLabel = new Label("0/0");
    }

    void makeLayout() {
        import gtk.Box : Box;
        import gtk.Separator : Separator;
        import gtkc.gtktypes : GtkOrientation;

        enum pad = 5;
        auto hbox = new Box(GtkOrientation.HORIZONTAL, pad);
        hbox.setHomogeneous(true);
        hbox.packStart(newButton, false, true, pad);
        hbox.packStart(optionsButton, false, true, pad);
        hbox.packStart(helpButton, false, true, pad);
        hbox.packStart(aboutButton, false, true, pad);
        hbox.packEnd(quitButton, false, true, pad);
        auto vbox = new Box(GtkOrientation.VERTICAL, pad);
        vbox.packStart(hbox, false, true, pad);
        vbox.packStart(board, true, true, pad);
        vbox.packEnd(statusLabel, false, true, pad);
        add(vbox);
    }

    void makeBindings() {
        newButton.addOnClicked(delegate void(Button) { onNew(); });
        optionsButton.addOnClicked(delegate void(Button) { onOptions(); });
        helpButton.addOnClicked(delegate void(Button) { onHelp(); });
        aboutButton.addOnClicked(delegate void(Button) { onAbout(); });
        quitButton.addOnClicked(delegate void(Button) { close(); });
        addOnDestroy(&onQuit);
    }

    void onNew() {
        import std.stdio: writeln; writeln("onNew");
    }

    void onOptions() {
        import std.stdio: writeln; writeln("onOptions");
    }

    void onHelp() {
        import std.stdio: writeln; writeln("onHelp");
    }

    void onAbout() {
        import aboutbox: about;
        about(this);
    }

    void onQuit(Widget) {
        import std.stdio: writeln; writeln("onQuit: save size/pos");

        destroy();
    }
}
