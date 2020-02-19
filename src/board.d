// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.DrawingArea: DrawingArea;
import std.typecons: Tuple;

alias Size = Tuple!(int, "width", int, "height");

final class Board : DrawingArea {
    import cairo.Context: Context, Scoped;
    import color: ACTIVE_BG_COLOR, Color;
    import gtk.Widget: Widget;
    import options: Options;
    import point: Point;

    enum State { PLAYING, GAME_OVER, USER_WON }

    enum Direction { UP, DOWN, LEFT, RIGHT }

    private void delegate(int, State) onChangeState;
    private auto options = Options();
    private State state;
    private int score;
    private Point selected;
    private Color[][] tiles;

    this(void delegate(int, State) onChangeState) {
        this.onChangeState = onChangeState;
        setSizeRequest(150, 150); // Minimum size
        addOnDraw(&onDraw);
        setRedrawOnAllocate(true);
        newGame();
    }

    void newGame() {
        import color: GAME_COLORS;
        import std.array: array;
        import std.random: choice, Random, randomSample, unpredictableSeed;

        state = State.PLAYING;
        score = 0;
        selected = Point();
        auto rnd = Random(unpredictableSeed);
        auto colors = GAME_COLORS.randomSample(options.maxColors, rnd);
        tiles = new Color[][](options.columns, options.rows);
        for (int x = 0; x < options.columns; x++) {
            for (int y = 0; y < options.rows; y++) {
                tiles[x][y] = colors.array.choice(rnd);
            }
        }
        doDraw();
        onChangeState(score, state);
    }

    private void doDraw(int delayMs = 0) {
        if (delayMs > 0) {
            import glib.Timeout: Timeout;

            new Timeout(delayMs, delegate bool() {
                queueDraw();
                return false;
            }, false);
        } else
            queueDraw();
    }

    private bool onDraw(Scoped!Context context, Widget) {
        import std.algorithm: min;
        import std.conv: to;
        import std.math: round;

        immutable size = tileSize();
        immutable edge = round(min(size.width, size.height) / 9).to!int;
        for (int x = 0; x < options.columns; x++)
            for (int y = 0; y < options.rows; y++)
                drawTile(context, x, y, size, edge);
        return true;
    }

    private Size tileSize() {
        return Size(getAllocatedWidth() / options.columns,
                    getAllocatedHeight() / options.rows);
    }

    private void drawTile(ref Scoped!Context context, const int x,
                          const int y, const Size size, const int edge) {
        context.save();
        scope(exit) context.restore();
        immutable x1 = x * size.width;
        immutable y1 = y * size.height;
        immutable color = tiles[x][y];
        if (!color.isValid()) {
            context.rectangle(x1, y1, size.width, size.height);
            context.setSourceRgb(ACTIVE_BG_COLOR.toRgb.expand);
            context.fill();
        } else {
            import cairo.Pattern: Pattern;

            immutable edge2 = edge * 2;
            immutable x2 = x1 + size.width;
            immutable y2 = y1 + size.height;
            immutable colors = colorPair(color);
            drawSegments(context, edge, colors, x1, y1, x2, y2);
            auto gradient = Pattern.createLinear(x1, y1, size.width,
                                                 size.height);
            gradient.addColorStopRgb(0, colors.light.toRgb.expand);
            gradient.addColorStopRgb(1, colors.dark.toRgb.expand);
            context.rectangle(x1 + edge, y1 + edge, size.width - edge2,
                              size.height - edge2);
            context.setSource(gradient);
            context.fill();
            // TODO
        }
    }

    private Color.Pair colorPair(Color color) {
        auto lighten = 0.5;
        auto darken = -0.5;
        if (state != State.PLAYING) {
            lighten = 0.25;
            darken = -0.75;
        }
        return Color.Pair(color.morphed(lighten), color.morphed(darken));
    }

    private void drawSegments(ref Scoped!Context context, const int edge,
                              const Color.Pair colors, const int x1,
                              const int y1, const int x2, const int y2) {
        drawSegment(context, colors.light, [x1, y1, x1 + edge, y1 + edge,
                    x2 - edge, y1 + edge, x2, y1]); // top
        drawSegment(context, colors.light, [x1, y1, x1, y2, x1 + edge,
                    y2 - edge, x1 + edge, y1 + edge]); // left
        drawSegment(context, colors.dark, [x2 - edge, y1 + edge, x2, y1, x2,
                    y2, x2 - edge, y2 - edge]); // right
        drawSegment(context, colors.dark, [x1, y2, x1 + edge, y2 - edge,
                    x2 - edge, y2 - edge, x2, y2]); // bottom
    }

    private void drawSegment(ref Scoped!Context context, const Color color,
                             const int[] points) {
        context.save();
        scope(exit) context.restore();
        context.moveTo(points[0], points[1]);
        for (int i = 2; i < points.length; i += 2)
            context.lineTo(points[i], points[i + 1]);
        context.closePath();
        context.setSourceRgb(color.toRgb.expand);
        context.fill();
    }

    // TODO mouse & keyboard & game logic
}
