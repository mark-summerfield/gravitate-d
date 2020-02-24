// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.Window: Window;

final class HelpForm: Window {
    import common: APPNAME;
    import gdk.Event: Event;
    import gtk.TextView: TextView;
    import gtk.Widget: Widget;

    private TextView view;

    this(Window parent) {
        super("Help — " ~ APPNAME);
        setTransientFor(parent);
        setDefaultSize(400, 400);
        makeView();
        populateView();
        makeLayout();
        addOnKeyPress(&onKeyPress);
        showAll;
        view.grabFocus;
    }

    void makeView() {
        import gtk.c.types: GtkWrapMode;

        view = new TextView;
        view.setCursorVisible(false);
        view.setEditable(false);
        view.setWrapMode(GtkWrapMode.WORD);
    }

    void populateView() {
        import gtk.c.types: Justification;
        import gtk.TextIter: TextIter;
        import pango.c.types: PANGO_SCALE, PangoWeight, PangoUnderline;

        auto buffer = view.getBuffer();
		auto iter = new TextIter();
        buffer.getIterAtOffset(iter, 0);
        buffer.createTag("title",
                         "weight", PangoWeight.BOLD,
                         "size", 14 * PANGO_SCALE,
                         "foreground", "navy",
                         "justification", cast(int)Justification.CENTER);
        buffer.createTag("header",
                         "weight", PangoWeight.BOLD,
                         "size", 11 * PANGO_SCALE,
                         "foreground", "darkgreen",
                         "underline", cast(int)PangoUnderline.SINGLE);
        buffer.createTag("key",
                         "weight", PangoWeight.BOLD,
                         "size", 11 * PANGO_SCALE);
        buffer.insertWithTagsByName(iter, "Gravitate\n\n", "title");
        buffer.insert(iter, BODY);
        buffer.insertWithTagsByName(iter, "Key — Action\n", "header");

        void insertKeyDesc(string key, string desc, string key2="") {
            buffer.insertWithTagsByName(iter, key, "key");
            if (key2.length) {
                buffer.insert(iter, " or ");
                buffer.insertWithTagsByName(iter, key2, "key");
            }
            buffer.insert(iter, " — " ~ desc ~ "\n");
        }
        insertKeyDesc("a", "About");
        insertKeyDesc("h", "Help (this window)", "F1");
        insertKeyDesc("n", "New game");
        insertKeyDesc("o", "Options");
        insertKeyDesc("q", "Quit", "Esc");
        insertKeyDesc("←", "Move left");
        insertKeyDesc("→", "Move right");
        insertKeyDesc("↑", "Move up");
        insertKeyDesc("↓", "Move down");
        insertKeyDesc("Space", "Delete focused tile");
    }

    void makeLayout() {
        import gtk.VPaned: VPaned;
        import gtk.ScrolledWindow: PolicyType, ScrolledWindow;

        auto paned = new VPaned;
        add(paned);
		auto scroll = new ScrolledWindow(PolicyType.AUTOMATIC,
                                         PolicyType.AUTOMATIC);
		scroll.add(view);
		paned.add1(scroll);
    }

    private bool onKeyPress(Event event, Widget) {
        import gdk.Keymap: Keymap;
        import std.algorithm: among;

        uint kv;
        event.getKeyval(kv);
        auto name = Keymap.keyvalName(kv);
        if (name.among("q", "Q", "Escape")) {
            destroy;
            return true;
        }
        return false;
    }
}

private auto BODY = q"EOT
The purpose of the game is to remove all the tiles.

Click a tile that has at least one vertically or horizontally adjoining tile of the same color to remove it and any vertically or horizontally adjoining tiles of the same color, and their vertically or horizontally adjoining tiles, and so on. (So clicking a tile with no adjoining tiles of the same color does nothing.)

The more tiles that are removed in one go, the higher the score.

Gravitate works like TileFall and the SameGame except that instead of tiles falling to the bottom and moving off to the left, they “gravitate” to the middle.

EOT";
