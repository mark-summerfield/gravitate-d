// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.DrawingArea: DrawingArea;

final class Board: DrawingArea {
    import cairo.Context: Context, Scoped;
    import common: ACTIVE_BG_COLOR;
    import gtk.Widget: Widget;
    import options: Options;

    enum State { PLAYING, GAME_OVER, USER_WON }
    enum Direction { UP, DOWN, LEFT, RIGHT }
    private enum UNSELECTED = -1;
    private auto options = Options();

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

    void newGame() {
        import std.random: Random, uniform, unpredictableSeed;

        auto rnd = Random(unpredictableSeed);

        // TODO
    }

    // TODO mouse & keyboard & game logic
}
