// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.ApplicationWindow: ApplicationWindow;

final class GameWindow: ApplicationWindow {
    import board: Board;
    import config: config;
    import gdk.Event: Event;
    import gtk.Application: Application;
    import gtk.Label: Label;
    import gtk.ToolButton: ToolButton;
    import gtk.Widget: Widget;

    private {
        ToolButton newButton;
        ToolButton optionsButton;
        ToolButton helpButton;
        ToolButton aboutButton;
        ToolButton quitButton;
        Board board;
        Label statusLabel;
    }

    this(Application application) {
        import common: APPNAME, ICON;

        super(application);
        setTitle(APPNAME);
        setIconFromFile(ICON); // TODO embed or SVG
        makeWidgets;
        makeLayout;
        makeBindings;
        addOnKeyPress(&onKeyPress);
        setDefaultSize(config.width, config.height);
        if (config.xyIsValid)
            move(config.x, config.y);
        showAll;
        board.newGame;
    }

    private void makeWidgets() {
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
        board = new Board(&onChangeState);
        statusLabel = new Label("0/0");
    }

    private void makeLayout() {
        import gtk.Box: Box;
        import gtkc.gtktypes: GtkOrientation;

        enum Pad = 1;
        enum: bool {Expand = true, Fill = true,
                    NoExpand = false, NoFill = false}
        auto leftBox = new Box(GtkOrientation.HORIZONTAL, Pad);
        leftBox.setHomogeneous(true);
        leftBox.packStart(newButton, NoExpand, Fill, Pad);
        leftBox.packStart(optionsButton, NoExpand, Fill, Pad);
        leftBox.packStart(helpButton, NoExpand, Fill, Pad);
        leftBox.packStart(aboutButton, NoExpand, Fill, Pad);
        auto hbox = new Box(GtkOrientation.HORIZONTAL, Pad);
        hbox.packStart(leftBox, NoExpand, NoFill, Pad);
        hbox.packEnd(quitButton, NoExpand, Fill, Pad);
        auto vbox = new Box(GtkOrientation.VERTICAL, Pad);
        vbox.packStart(hbox, NoExpand, Fill, Pad);
        vbox.packStart(board, Expand, Fill, Pad);
        vbox.packEnd(statusLabel, NoExpand, Fill, Pad);
        add(vbox);
    }

    private void makeBindings() {
        newButton.addOnClicked(&onNew);
        optionsButton.addOnClicked(&onOptions);
        helpButton.addOnClicked(&onHelp);
        aboutButton.addOnClicked(&onAbout);
        quitButton.addOnClicked(
            delegate void(ToolButton) { onQuit(null); });
        addOnDelete(
            delegate bool(Event, Widget) { onQuit(null); return false; });
    }

    // These are application-global since we don't want a notion of focus
    private bool onKeyPress(Event event, Widget) {
        import gdk.Keymap: Keymap;

        uint kv;
        event.getKeyval(kv);
        switch (Keymap.keyvalName(kv)) {
        case "n", "N":
            onNew(null);
            return true;
        case "o", "O":
            onOptions(null);
            return true;
        case "h", "H", "F1":
            onHelp(null);
            return true;
        case "a", "A":
            onAbout(null);
            return true;
        case "q", "Q", "Escape":
            onQuit(null);
            return true;
        case "Left":
            board.navigate(Board.Direction.LEFT);
            return true;
        case "Right":
            board.navigate(Board.Direction.RIGHT);
            return true;
        case "Up":
            board.navigate(Board.Direction.UP);
            return true;
        case "Down":
            board.navigate(Board.Direction.DOWN);
            return true;
        case "space":
            board.chooseTile;
            return true;
        default:
            return false;
        }
    }

    private void onNew(ToolButton) {
        board.newGame;
    }

    private void onOptions(ToolButton) {
        import optionsform: OptionsForm;
        new OptionsForm(this);
    }

    private void onHelp(ToolButton) {
        import helpform: HelpForm;
        new HelpForm(this);
    }

    private void onAbout(ToolButton) {
        import aboutbox: about;
        about(this);
    }

    private void onQuit(Widget) {
        int a;
        int b;
        getSize(a, b);
        config.width = a;
        config.height = b;
        getPosition(a, b);
        config.x = a;
        config.y = b;
        config.save;
        destroy;
    }

    private void onChangeState(int score, Board.State state) {
        import std.format: format;

        auto message = format("%,d/%,d ", score, config.highScore);
        if (state == Board.State.GAME_OVER)
            message ~= "Game Over";
        else if (state == Board.State.USER_WON) {
            if (score > config.highScore) {
                message ~= "New High Score!";
                config.highScore = score;
                config.save;
            } else
                message ~= "You Won!";
        }
	    statusLabel.setText(message);
    }
}
