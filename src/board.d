// Copyright © 2020 Mark Summerfield. All rights reserved.
module qtrac.gravitate.board;

import gtk.DrawingArea: DrawingArea;

final class Board: DrawingArea {
    import aaset: AAset;
    import cairo.Context: Context, Scoped;
    import gdk.Event: Event;
    import glib.c.types: GPriority;
    import gtk.Widget: Widget;
    import qtrac.gravitate.color: Color;
    import qtrac.gravitate.config: config;
    import qtrac.gravitate.point: Point;
    import std.typecons: Tuple;

    enum Direction { UP, DOWN, LEFT, RIGHT }
    enum State { PLAYING, GAME_OVER, USER_WON }

    private {
        alias Size = Tuple!(int, "width", int, "height");
        alias OnChangeStateFn = void delegate(int, State);
        alias PointSet = AAset!Point;
        alias PointMap = Point[Point];
        alias MovePoint = Tuple!(bool, "move", Point, "point");

        OnChangeStateFn onChangeState;
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
    }

    void newGame() {
        import qtrac.gravitate.color: COLORS;
        import std.algorithm: each;
        import std.array: array;
        import std.random: choice, randomSample;

        state = State.PLAYING;
        score = 0;
        selected.clear;
        auto colors = COLORS.byKey.array.randomSample(config.maxColors)
            .array;
        tiles = new Color[][](config.columns, config.rows);
        each!(xy => tiles[xy[0]][xy[1]] = colors.choice)
             (allTilesRange);
        queueDraw;
        onChangeState(score, state);
    }

    private auto allTilesRange() {
        import std.algorithm: cartesianProduct;
        import std.range: iota;
        return cartesianProduct(iota(config.columns), iota(config.rows));
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
        return Size(getAllocatedWidth / config.columns,
                    getAllocatedHeight / config.rows);
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

    private Color.Pair colorPair(Color color) const {
        import qtrac.gravitate.color: COLORS;

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
        import std.algorithm: each;
        import std.range: iota;

        context.newPath;
        context.moveTo(points[0], points[1]);
        each!(i => context.lineTo(points[i], points[i + 1]))
             (iota(0, points.length, 2));
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
        queueDraw; // Force redraw since sometimes Gtk "forgets" to
        if (state == State.PLAYING) {
            import std.conv: to;
            import std.math: floor;

            immutable size = tileSize;
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
            selected.x = config.columns / 2;
            selected.y = config.rows / 2;
        } else {
            int x = selected.x;
            int y = selected.y;
            final switch (direction) {
            case Direction.LEFT: x--; break;
            case Direction.RIGHT: x++; break;
            case Direction.UP: y--; break;
            case Direction.DOWN: y++; break;
            }
            if (0 <= x && x < config.columns && 0 <= y && y < config.rows
                    && tiles[x][y].isValid) {
                selected.x = x;
                selected.y = y;
            }
        }
        queueDraw;
    }

    void chooseTile() {
        if (state == State.PLAYING && selected.isValid)
            deleteTiles(selected);
    }

    private void deleteTiles(const Point p) {
        import glib.Timeout: Timeout;

        immutable color = tiles[p.x][p.y];
        if (!color.isValid || !isLegal(p, color))
            return;
        const adjoining = dimAdjoining(p, color);
        queueDraw;
        new Timeout(config.delayMs, delegate bool() {
            deleteAdjoining(adjoining); return false; },
            GPriority.HIGH, false);
    }

    private bool isLegal(const Point p, const Color color) const {
        immutable x = p.x;
        immutable y = p.y;
        if (x > 0 && color == tiles[x - 1][y])
            return true;
        if (x + 1 < config.columns && color == tiles[x + 1][y])
            return true;
        if (y > 0 && color == tiles[x][y - 1])
            return true;
        if (y + 1 < config.rows && color == tiles[x][y + 1])
            return true;
        return false;
    }

    private PointSet dimAdjoining(const Point p, const Color color) {
        import std.algorithm: each;

        PointSet adjoining;
        populateAdjoining(p, color, adjoining);
        each!(ap => tiles[ap.x][ap.y] = tiles[ap.x][ap.y].darker)
             (adjoining);
        return adjoining;
    }

    private void populateAdjoining(const Point p, const Color color,
                                   ref PointSet adjoining) {
        immutable x = p.x;
        immutable y = p.y;
        if (!(0 <= x && x < config.columns && 0 <= y && y < config.rows))
            return; // Fallen off an edge
        if (p in adjoining || tiles[x][y] != color)
            return; // Color doesn't match or already done
        adjoining.add(p);
        populateAdjoining(Point(x - 1, y), color, adjoining);
        populateAdjoining(Point(x + 1, y), color, adjoining);
        populateAdjoining(Point(x, y - 1), color, adjoining);
        populateAdjoining(Point(x, y + 1), color, adjoining);
    }

    private void deleteAdjoining(const PointSet adjoining) {
        import glib.Timeout: Timeout;
        import std.algorithm: each;

        queueDraw;
        immutable invalid = Color();
        each!(ap => tiles[ap.x][ap.y] = invalid)(adjoining);
        new Timeout(config.delayMs, delegate bool() {
            closeTilesUp(adjoining.length); return false; },
            GPriority.HIGH, false);
    }

    private void closeTilesUp(const size_t count) {
        import glib.Timeout: Timeout;
        import std.conv: to;
        import std.math: pow, round, sqrt;

        queueDraw;
        moveTiles;
        if (selected.isValid) {
            if (!tiles[selected.x][selected.y].isValid) {
                selected.x = config.columns / 2;
                selected.y = config.rows / 2;
            }
        }
        score += (round(sqrt(config.columns * config.rows.to!double)) +
                  pow(count, config.maxColors / 2)).to!int;
        checkGameOver;
        onChangeState(score, state);
        new Timeout(config.delayMs, delegate bool() {
            queueDraw; return false; }, GPriority.HIGH, false);
    }

    private void moveTiles() {
        bool moved = true;
        PointMap moves;
        while (moved) {
            moved = false;
            foreach (x; rippleRange(config.columns))
                foreach (y; rippleRange(config.rows))
                    if (tiles[x][y].isValid &&
                            moveIsPossible(x, y, moves)) {
                        moved = true;
                        break;
                    }
        }
    }

    private int[] rippleRange(const int limit) {
        import std.array: array;
        import std.range: iota;
        import std.random: randomShuffle;
        return iota(limit).array.randomShuffle;
    }

    private bool moveIsPossible(const int x, const int y,
                                ref PointMap moves) {
        import std.range: empty;

        immutable p = Point(x, y);
        auto empties = emptyNeighbours(x, y);
        if (!empties.empty) {
            immutable mp = nearestToMiddle(x, y, empties);
            immutable np = mp.point;
            auto seen = np in moves;
            if (seen !is null && *seen == p)
                return false; // Avoid endless loop back and forth
            if (mp.move) {
                tiles[np.x][np.y] = tiles[x][y];
                tiles[x][y] = Color(); // invalid color
                moves[p] = np;
                return true;
            }
        }
        return false;
    }

    private PointSet emptyNeighbours(const int x, const int y) {
        PointSet neighbours;
        foreach (p; [Point(x - 1, y), Point(x + 1, y), Point(x, y - 1),
                     Point(x, y + 1)])
            if (0 <= p.x && p.x < config.columns && 0 <= p.y &&
                    p.y < config.rows && !tiles[p.x][p.y].isValid)
                neighbours.add(p);
        return neighbours;
    }

    private MovePoint nearestToMiddle(const int x, const int y,
                                      const PointSet empties) {
        import std.math: hypot, isNaN;

        immutable color = tiles[x][y];
        immutable midx = config.columns / 2;
        immutable midy = config.rows / 2;
        immutable oldRadius = hypot(midx - x, midy - y);
        double shortestRadius;
        Point rp;
        foreach (p; empties) {
            if (isSquare(p)) {
                auto newRadius = hypot(midx - p.x, midy - p.y);
                if (isLegal(p, color))
                    newRadius -= 0.1; // Make same colors slightly attract
                if (!rp.isValid || shortestRadius > newRadius) {
                    shortestRadius = newRadius;
                    rp = p;
                }
            }
        }
        if (!isNaN(shortestRadius) && oldRadius > shortestRadius)
            return MovePoint(true, rp);
        return MovePoint(false, Point(x, y));
    }

    bool isSquare(const Point p) const {
        immutable x = p.x;
        immutable y = p.y;
        if (x > 0 && tiles[x - 1][y].isValid)
            return true;
        if (x + 1 < config.columns && tiles[x + 1][y].isValid)
            return true;
        if (y > 0 && tiles[x][y - 1].isValid)
            return true;
        if (y + 1 < config.rows && tiles[x][y + 1].isValid)
            return true;
        return false;
    }

    private void checkGameOver() {
        import std.algorithm: any, each;

        int[Color] countForColor;
        bool userWon = true;
        bool canMove = false;

        void check(const int x, const int y) {
            immutable color = tiles[x][y];
            if (color.isValid) {
                userWon = false;
                countForColor[color]++;
                if (isLegal(Point(x, y), color))
                    canMove = true;
            }
        }

        each!(xy => check(xy[0], xy[1]))(allTilesRange);
        if (any!(a => a == 1)(countForColor.byValue))
            canMove = false;

        if (userWon)
            state = State.USER_WON;
        else if (!canMove)
            state = State.GAME_OVER;
    }
}
