// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.Window: Window;

final class HelpForm: Window {
    import common: APPNAME;
    import gtk.TextBuffer: TextBuffer;
    import gtk.TextView: TextView;

    private {
        TextBuffer buffer;
        TextView view;
    }

    this(Window window) {
        super("Help — " ~ APPNAME);
        setTransientFor(window);

        showAll;
    }
}
