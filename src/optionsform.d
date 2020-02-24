// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.Dialog: Dialog;

final class OptionsForm: Dialog {
    import common: APPNAME;
    import gtk.Window: Window;

    private {
    }

    this(Window parent) {
        import gtk.c.types: GtkDialogFlags, GtkResponseType;
        import gtkc.gtktypes: StockID;

        super("Options — " ~ APPNAME, parent, GtkDialogFlags.MODAL,
              [StockID.OK, StockID.CANCEL],
              [GtkResponseType.OK, GtkResponseType.CANCEL]);
        setTransientFor(parent);

        showAll;
    }
}
