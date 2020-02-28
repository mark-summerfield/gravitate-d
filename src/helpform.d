// Copyright © 2020 Mark Summerfield. All rights reserved.
module qtrac.gravitate.helpform;

import gtk.Window: Window;

final class HelpForm: Window {
    import gdk.Event: Event;
    import gtk.TextView: TextView;
    import gtk.Widget: Widget;
    import qtrac.gravitate.common: APPNAME;

    private TextView view;
    private enum SIZE = 400;

    this(Window parent) {
        super("Help — " ~ APPNAME);
        setTransientFor(parent);
        setDefaultSize(SIZE, SIZE);
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
        import pango.PgTabArray: PgTabArray;
        import pango.c.types: PANGO_SCALE, PangoTabAlign, PangoWeight,
               PangoUnderline;

        auto tabs = new PgTabArray(1, true);
        tabs.setTab(0, PangoTabAlign.LEFT, SIZE / 5);
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
                         "underline", cast(int)PangoUnderline.SINGLE,
                         "tabs", tabs);
        buffer.createTag("key",
                         "weight", PangoWeight.BOLD,
                         "size", 11 * PANGO_SCALE,
                         "tabs", tabs);
        buffer.createTag("desc",
                         "size", 11 * PANGO_SCALE);
        buffer.insertWithTagsByName(iter, "Gravitate\n\n", "title");
        buffer.insert(iter, import("data/help.txt"));
        buffer.insertWithTagsByName(iter, "Key\tAction\n", "header");

        void insertKeyDesc(string key, string desc, string key2="") {
            buffer.insertWithTagsByName(iter, key, "key");
            if (key2.length) {
                buffer.insert(iter, " or ");
                buffer.insertWithTagsByName(iter, key2, "key");
            }
            buffer.insertWithTagsByName(iter, "\t" ~ desc ~ "\n", "desc");
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
        import gtk.ScrolledWindow: PolicyType, ScrolledWindow;

		auto scroll = new ScrolledWindow(PolicyType.AUTOMATIC,
                                         PolicyType.AUTOMATIC);
		scroll.add(view);
        add(scroll);
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
