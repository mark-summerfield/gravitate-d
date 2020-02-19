// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.ApplicationWindow: ApplicationWindow;

final class GameWindow : ApplicationWindow {
    import board: Board;
    import gdk.Event: Event;
    import gtk.Application: Application;
    import gtk.Label: Label;
    import gtk.ToolButton: ToolButton;
    import gtk.Widget: Widget;

    private ToolButton newButton;
    private ToolButton optionsButton;
    private ToolButton helpButton;
    private ToolButton aboutButton;
    private ToolButton quitButton;
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
        addOnKeyPress(&onKeyPress);
        // TODO load size/pos (with default fallbacks)
        immutable width = 400;
        immutable height = 400;
        setDefaultSize(width, height);
        showAll();
    }

    void makeWidgets() {
        import gtk.IconSize: IconSize;
        import gtk.Image: Image;
        import gtkc.gtktypes: StockID;

        newButton = new ToolButton(StockID.NEW);
        newButton.setTooltipMarkup("New <b>n</b>");
        optionsButton = new ToolButton(StockID.PREFERENCES);
        optionsButton.setTooltipMarkup("Options <b>o</b>");
        helpButton = new ToolButton(StockID.HELP);
        helpButton.setTooltipMarkup("Help <b>h</b> <i>or</i> <b>F1</b>");
        aboutButton = new ToolButton(StockID.ABOUT);
        aboutButton.setTooltipMarkup("About <b>a</b>");
        quitButton = new ToolButton(StockID.QUIT);
        quitButton.setTooltipMarkup("Quit <b>q</b> <i>or</i> <b>Esc</b>");
        board = new Board(&onChangeScore);
        statusLabel = new Label("0/0");
    }

    void makeLayout() {
        import gtk.Box: Box;
        import gtkc.gtktypes: GtkOrientation;

        enum pad = 1;
        enum Expand = true;
        enum NoExpand = false;
        enum Fill = true;
        enum NoFill = false;
        auto leftBox = new Box(GtkOrientation.HORIZONTAL, pad);
        leftBox.setHomogeneous(true);
        leftBox.packStart(newButton, NoExpand, Fill, pad);
        leftBox.packStart(optionsButton, NoExpand, Fill, pad);
        leftBox.packStart(helpButton, NoExpand, Fill, pad);
        leftBox.packStart(aboutButton, NoExpand, Fill, pad);
        auto hbox = new Box(GtkOrientation.HORIZONTAL, pad);
        hbox.packStart(leftBox, NoExpand, NoFill, pad);
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
        quitButton.addOnClicked(delegate void(ToolButton) { close(); });
        addOnDestroy(&onQuit);
    }

    void onNew(ToolButton) {
        import std.stdio: writeln;
        writeln("onNew"); // TODO
    }

    void onOptions(ToolButton) {
        import std.stdio: writeln;
        writeln("onOptions"); // TODO
    }

    void onHelp(ToolButton) {
        import std.stdio: writeln;
        writeln("onHelp"); // TODO
    }

    void onAbout(ToolButton) {
        import aboutbox: about;
        about(this);
    }

    void onQuit(Widget) {
        import std.stdio: writeln;
        writeln("onQuit: save size/pos"); // TODO
        destroy();
    }

    void onChangeScore(int score, Board.State state) {
        // TODO
        import std.stdio: writefln;
        writefln("onChangeScore %s %s", score, state);
    }

    bool onKeyPress(Event event, Widget) {
        import std.conv: to;
        import gdk.Keymap: Keymap;

        // FIXME surely there's a nicer way!
        ushort kc;
        event.getKeycode(kc);
        version(Windows) {
            immutable help = 112;
            immutable esc = 27;
        }
        version(Posix) {
            immutable help = 67;
            immutable esc = 9;
        }
        if (kc == help) {
            onHelp(null);
            return true;
        } else if (kc == esc) {
            onQuit(null);
            return true;
        }
        uint kv;
        event.getKeyval(kv);
        switch (Keymap.keyvalToUnicode(kv)) {
            case 'n'.to!uint: onNew(null); return true;
            case 'o'.to!uint: onOptions(null); return true;
            case 'h'.to!uint: onHelp(null); return true;
            case 'a'.to!uint: onAbout(null); return true;
            case 'q'.to!uint: onQuit(null); return true;
            default: return false;
        }
    }
}
