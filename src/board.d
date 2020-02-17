// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.DrawingArea: DrawingArea;

final class Board: DrawingArea {
    import cairo.Context: Context, Scoped;
    import common: ACTIVE_BG_COLOR;
    import gtk.Widget: Widget;

    this() {
        setSizeRequest(150, 150); // Minimum size
        addOnDraw(&onDraw);
        setRedrawOnAllocate(true);
    }

    bool onDraw(Scoped!Context context, Widget) {
        const width = getAllocatedWidth();
        const height = getAllocatedHeight();
        context.rectangle(0, 0, width, height);
        context.setSourceRgb(ACTIVE_BG_COLOR.expand);
        context.fill();
        // TODO

        return true;
    }

    // TODO mouse & keyboard & game logic
}
