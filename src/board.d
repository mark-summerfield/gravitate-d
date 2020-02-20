// Copyright © 2020 Mark Summerfield. All rights reserved.

import gtk.DrawingArea: DrawingArea;

final class Board : DrawingArea {
    import cairo.Context: Context, Scoped;
    import color: Color;
    import gdk.Event: Event;
    import gtk.Widget: Widget;
    import options: Options;
    import point: Point;
    import std.container.rbtree: RedBlackTree;
    import std.typecons: Tuple;

    enum Direction { UP, DOWN, LEFT, RIGHT }
    enum State { PLAYING, GAME_OVER, USER_WON }

    private {
        alias Size = Tuple!(int, "width", int, "height");
        alias OnChangeStateFn = void delegate(int, State);
        alias PointSet = RedBlackTree!Point;
        alias PointMap = Point[Point];

        OnChangeStateFn onChangeState;
        auto options = Options();
        State state;
        int score;
        Point selected;
        Color[][] tiles;
    }

    this(OnChangeStateFn onChangeState) {
        this.onChangeState = onChangeState;
        setSizeRequest(150, 150); // Minimum size
        addOnDraw(&onDraw);
        addOnButtonPress(&onMouseButtonPress);
        setRedrawOnAllocate(true);
        newGame;
    }

    void newGame() {
        import color: COLORS;
        import std.algorithm: each;
        import std.array: array;
        import std.random: choice, Random, randomSample, unpredictableSeed;

        state = State.PLAYING;
        score = 0;
        selected.clear();
        auto rnd = Random(unpredictableSeed);
        auto colors = COLORS.byKey.array.randomSample(options.maxColors,
                                                      rnd);
        tiles = new Color[][](options.columns, options.rows);
        each!(xy => tiles[xy[0]][xy[1]] = colors.array.choice(rnd))
             (allTilesRange);
        doDraw;
        onChangeState(score, state);
    }

    private auto allTilesRange() {
        import std.algorithm: cartesianProduct;
        import std.range: iota;
        return cartesianProduct(iota(options.columns), iota(options.rows));
    }

    private void doDraw(const int delayMs=0) {
        if (delayMs > 0) {
            import glib.Timeout: Timeout;
            new Timeout(delayMs, delegate bool() {
                queueDraw; return false; }, false);
        } else
            queueDraw;
    }

    private bool onDraw(Scoped!Context context, Widget) {
        import std.algorithm: each, min;
        import std.conv: to;
        import std.math: round;

        immutable size = tileSize;
        immutable edge = round(min(size.width, size.height) / 9).to!int;
        each!(xy => drawTile(context, xy[0], xy[1], size, edge))
             (allTilesRange);
        return true;
    }

    private Size tileSize() {
        return Size(getAllocatedWidth / options.columns,
                    getAllocatedHeight / options.rows);
    }

    private void drawTile(ref Scoped!Context context, const int x,
                          const int y, const Size size, const int edge) {
        immutable x1 = x * size.width;
        immutable y1 = y * size.height;
        immutable color = tiles[x][y];
        if (!color.isValid) {
            context.rectangle(x1, y1, size.width, size.height);
            context.setSourceRgb(Color.BACKGROUND.toRgb.expand);
            context.fill;
        } else {
            import cairo.Pattern: Pattern;

            immutable x2 = x1 + size.width;
            immutable y2 = y1 + size.height;
            immutable colors = colorPair(color);
            drawSegments(context, edge, colors, x1, y1, x2, y2);
            auto gradient = Pattern.createLinear(x1, y1, x2, y2);
            gradient.addColorStopRgb(0, colors.light.toRgb.expand);
            gradient.addColorStopRgb(1, colors.dark.toRgb.expand);
            immutable edge2 = edge * 2;
            context.rectangle(x1 + edge, y1 + edge, size.width - edge2,
                              size.height - edge2);
            context.setSource(gradient);
            context.fill;
            if (selected.x == x && selected.y == y)
                drawFocus(context, x1, y1, size);
        }
    }

    private Color.Pair colorPair(Color color) {
        import color: COLORS;

        immutable plight = color in COLORS;
        Color light = plight is null ? Color.BACKGROUND : *plight;
        auto dark = color;
        if (state != State.PLAYING) {
            light = light.darker;
            dark = dark.darker;
        }
        return Color.Pair(light, dark);
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
        context.newPath;
        context.moveTo(points[0], points[1]);
        for (int i = 2; i < points.length; i += 2)
            context.lineTo(points[i], points[i + 1]);
        context.closePath;
        context.setSourceRgb(color.toRgb.expand);
        context.fill;
    }

    private void drawFocus(ref Scoped!Context context, const int x1,
                           const int y1, const Size size) {
        import std.algorithm: min;
        import std.math: fmax, fmin;

        immutable indent = fmax(2, min(size.width, size.height) / 8.0);
        immutable indent2 = indent * 2.5;
        context.setDash([1.5], 0);
        context.rectangle(x1 + indent, y1 + indent, size.width - indent2,
                          size.height - indent2);
        context.setSourceRgb(Color.FOCUS_RECT.toRgb.expand);
        context.stroke;
    }

    private bool onMouseButtonPress(Event event, Widget) {
        if (state == State.PLAYING) {
            import std.conv: to;
            import std.math: floor;

            auto size = tileSize;
            double eventX;
            double eventY;
            event.getCoords(eventX, eventY);
            immutable x = floor(eventX / size.width).to!int;
            immutable y = floor(eventY / size.height).to!int;
            selected.clear;
            deleteTiles(Point(x, y));
        }
        return true;
    }

    void navigate(const Direction direction) {
        if (state != State.PLAYING)
            return;
        if (!selected.isValid) {
            selected.x = options.columns / 2;
            selected.y = options.rows / 2;
        } else {
            int x = selected.x;
            int y = selected.y;
            final switch (direction) {
            case Direction.LEFT: x--; break;
            case Direction.RIGHT: x++; break;
            case Direction.UP: y--; break;
            case Direction.DOWN: y++; break;
            }
            if (0 <= x && x < options.columns && 0 <= y && y < options.rows
                    && tiles[x][y].isValid) {
                selected.x = x;
                selected.y = y;
            }
        }
        doDraw;
    }

    void chooseTile() {
        if (state == State.PLAYING && selected.isValid)
            deleteTiles(selected);
    }

    private void deleteTiles(const Point p) {
        import glib.Timeout: Timeout;

        auto color = tiles[p.x][p.y];
        if (!color.isValid || !isLegal(p, color))
            return;
        auto adjoining = dimAdjoining(p, color);
        doDraw;
        new Timeout(options.delayMs, delegate bool() {
            deleteAdjoining(adjoining); return false; }, false);
    }

    private bool isLegal(const Point p, const Color color) {
        immutable x = p.x;
        immutable y = p.y;
        if (x > 0 && color == tiles[x - 1][y])
            return true;
        if (x + 1 < options.columns && color == tiles[x + 1][y])
            return true;
        if (y > 0 && color == tiles[x][y - 1])
            return true;
        if (y + 1 < options.rows && color == tiles[x][y + 1])
            return true;
        return false;
    }

    private PointSet dimAdjoining(const Point p, const Color color) {
        import std.algorithm: each;

        auto adjoining = new PointSet;
        populateAdjoining(p, color, adjoining);
        each!(ap => tiles[ap.x][ap.y] = tiles[ap.x][ap.y].darker)
             (adjoining);
        doDraw(options.delayMs);
        return adjoining;
    }

    private void populateAdjoining(const Point p, const Color color,
                                   ref PointSet adjoining) {
        immutable x = p.x;
        immutable y = p.y;
        if (!(0 <= x && x < options.columns && 0 <= y && y < options.rows))
            return; // Fallen off an edge
        if (p in adjoining || tiles[x][y] != color)
            return; // Color doesn't match or already done
        adjoining.insert(p);
        populateAdjoining(Point(x - 1, y), color, adjoining);
        populateAdjoining(Point(x + 1, y), color, adjoining);
        populateAdjoining(Point(x, y - 1), color, adjoining);
        populateAdjoining(Point(x, y + 1), color, adjoining);
    }

    private void deleteAdjoining(const PointSet adjoining) {
        import glib.Timeout: Timeout;
        import std.algorithm: each;

        auto invalid = Color();
        each!(ap => tiles[ap.x][ap.y] = invalid)(adjoining);
        doDraw(options.delayMs);
        new Timeout(options.delayMs, delegate bool() {
            closeTilesUp(adjoining.length); return false; }, false);
    }

    private void closeTilesUp(const size_t count) {
        moveTiles;
        if (selected.isValid) {
            if (!tiles[selected.x][selected.y].isValid) {
                selected.x = options.columns / 2;
                selected.y = options.rows / 2;
            }
        }
        doDraw; // TODO delay?
        // TODO calculate & report score: see nim
        // TODO checkGameOver
    }

    private void moveTiles() {
        bool moved = true;
        PointMap moves;
        while (moved) {
            moved = false;
            foreach (x; rippleRange(options.columns))
                foreach (y; rippleRange(options.rows))
                    if (tiles[x][y].isValid)
                        if (moveIsPossible(x, y, moves)) {
                            moved = true;
                            break;
                        }
        }
    }

    private int[] rippleRange(const int limit) {
        import std.array: array;
        import std.range: iota;
        import std.random: Random, randomShuffle, unpredictableSeed;

        auto rnd = Random(unpredictableSeed);
        return iota(limit).array.randomShuffle(rnd);
    }

    private bool moveIsPossible(const int x, const int y,
                                ref PointMap moves) {
        // TODO
        return false;
    }
}
