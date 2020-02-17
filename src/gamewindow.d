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
        setIconFromFile(ICON); // TODO embed or SVG
        makeWidgets();
        makeLayout();
        makeBindings();
        // TODO load size/pos (with default fallbacks)
        const width = 400;
        const height = 400;
        setDefaultSize(width, height);
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
        foreach (button; [newButton, optionsButton, helpButton, aboutButton,
                          quitButton])
            button.setAlwaysShowImage(true);
        board = new Board();
        statusLabel = new Label("0/0");
    }

    void makeLayout() {
        import gtk.Box : Box;
        import gtkc.gtktypes : GtkOrientation;

        enum pad = 5;
        enum Expand = true;
        enum NoExpand = false;
        enum Fill = true;
        auto hbox = new Box(GtkOrientation.HORIZONTAL, pad);
        hbox.setHomogeneous(true);
        hbox.packStart(newButton, NoExpand, Fill, pad);
        hbox.packStart(optionsButton, NoExpand, Fill, pad);
        hbox.packStart(helpButton, NoExpand, Fill, pad);
        hbox.packStart(aboutButton, NoExpand, Fill, pad);
        hbox.packEnd(quitButton, NoExpand, Fill, pad);
        auto vbox = new Box(GtkOrientation.VERTICAL, pad);
        vbox.packStart(hbox, NoExpand, Fill, pad);
        vbox.packStart(board, Expand, Fill, pad);
        vbox.packEnd(statusLabel, NoExpand, Fill, pad);
        add(vbox);
    }

    void makeBindings() {
        newButton.addOnClicked(&onNew);
        optionsButton.addOnClicked(&onOptions);
        helpButton.addOnClicked(&onHelp);
        aboutButton.addOnClicked(&onAbout);
        quitButton.addOnClicked(delegate void(Button) { close(); });
        addOnDestroy(&onQuit);
    }

    void onNew(Button) {
        import std.stdio: writeln; writeln("onNew"); // TODO
    }

    void onOptions(Button) {
        import std.stdio: writeln; writeln("onOptions"); // TODO
    }

    void onHelp(Button) {
        import std.stdio: writeln; writeln("onHelp"); // TODO
    }

    void onAbout(Button) {
        import aboutbox: about;
        about(this);
    }

    void onQuit(Widget) {
        import std.stdio: writeln; writeln("onQuit: save size/pos"); // TODO
        destroy();
    }
}
