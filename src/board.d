// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.DrawingArea: DrawingArea;

final class Board: DrawingArea {
    import cairo.Context: Context, Scoped;
    import gtk.Widget: Widget;

    this() {
        setSizeRequest(120, 120); // Minimum size
        addOnDraw(&onDraw);
        setRedrawOnAllocate(true);
    }

    bool onDraw(Scoped!Context context, Widget) {
        const width = getAllocatedWidth();
        const height = getAllocatedHeight();
        context.rectangle(0, 0, width, height);
        context.setSourceRgb(1, 0, 0); // TODO nice bg color
        context.fill();

        return true;
    }

    // TODO mouse & keyboard & game logic
}
