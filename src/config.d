// Copyright © 2020 Mark Summerfield. All rights reserved.

static Config config; // Must call config.load(applicationId) before use

private struct Config {
    import glib.KeyFile: KeyFile;
    import std.algorithm: clamp;

    int maxColors() const { return m.maxColors; }

    void maxColors(const int maxColors) {
        import color: COLORS;
        import std.conv: to;

        m.maxColors = clamp(maxColors, 2, COLORS.length.to!int);
    }

    int columns() const { return m.columns; }

    void columns(const int columns) {
        m.columns = clamp(columns, MIN_SIZE, MAX_SIZE);
    }

    int rows() const { return m.rows; }

    void rows(const int rows) {
        m.rows = clamp(rows, MIN_SIZE, MAX_SIZE);
    }

    int delayMs() const { return m.delayMs; }

    void delayMs(const int delayMs) {
        m.delayMs = clamp(delayMs, 0, 1000);
    }

    int highScore() const { return m.highScore; }

    void highScore(const int highScore) {
        m.highScore = clamp(highScore, 0, int.max);
    }

    int x() const { return m.x; }

    void x(const int x) {
        m.x = x;
    }

    int y() const { return m.y; }

    void y(const int y) {
        m.y = y;
    }

    bool xyIsValid() const { return m.x > INVALID && m.y > INVALID; }

    int width() const { return m.width; }

    void width(const int width) {
        m.width = clamp(width, 200, 2000);
    }

    int height() const { return m.height; }

    void height(const int height) {
        m.height = clamp(height, 200, 2000);
    }

    // Must be called before use of static
    void load(string applicationId) {
        import glib.Util: gutil = Util;
        import glib.c.types: GKeyFileFlags;
        import std.array: replace;
        import std.path: buildPath, dirSeparator;

        filename = buildPath(gutil.getUserConfigDir,
                             applicationId.replace('.',
                                                   dirSeparator) ~ ".ini");
        auto keyFile = new KeyFile;
        if (!keyFile.loadFromFile(filename, GKeyFileFlags.KEEP_COMMENTS)) {
            import std.stdio: stderr;
            stderr.writeln("failed to load config");
            return;
        }
        maxColors(get(keyFile, BOARD, MAXCOLORS, DEF_MAXCOLORS));
        columns(get(keyFile, BOARD, COLUMNS, DEF_COLUMNS));
        rows(get(keyFile, BOARD, ROWS, DEF_ROWS));
        delayMs(get(keyFile, BOARD, DELAYMS, DEF_DELAYMS));
        highScore(get(keyFile, BOARD, HIGHSCORE, DEF_HIGHSCORE));
        x(get(keyFile, WINDOW, X, INVALID));
        y(get(keyFile, WINDOW, Y, INVALID));
        width(get(keyFile, WINDOW, WIDTH, DEF_WIDTH));
        height(get(keyFile, WINDOW, HEIGHT, DEF_HEIGHT));
    }

    private T get(T)(ref KeyFile keyFile, string group, string key,
                     const T defaultValue) {
        auto value = keyFile.getValue(group, key);
        if (value !is null) {
            import std.conv: ConvException, to;
            try {
                return value.to!T;
            } catch (ConvException) {
                // ignore and return default
            }
        }
        return defaultValue;
    }

    bool save() {
        assert(filename.length);

        import std.file: exists, FileException, mkdirRecurse;
        import std.path: dirName;

        immutable path = dirName(filename);
        if (!path.exists)
            try {
                mkdirRecurse(path);
            } catch (FileException err) {
                import std.stdio: stderr;
                stderr.writefln("failed to create config path: %s", err);
                return false;
            }
        auto keyFile = new KeyFile;
        keyFile.setInteger(BOARD, MAXCOLORS, maxColors);
        keyFile.setInteger(BOARD, COLUMNS, columns);
        keyFile.setInteger(BOARD, ROWS, rows);
        keyFile.setInteger(BOARD, DELAYMS, delayMs);
        keyFile.setInteger(BOARD, HIGHSCORE, highScore);
        keyFile.setInteger(WINDOW, X, x);
        keyFile.setInteger(WINDOW, Y, y);
        keyFile.setInteger(WINDOW, WIDTH, width);
        keyFile.setInteger(WINDOW, HEIGHT, height);
        if (!keyFile.saveToFile(filename)) {
            import std.stdio: stderr;
            stderr.writeln("failed to save config");
            return false;
        }
        return true;
    }

    private {
        enum BOARD = "Board";
        enum WINDOW = "Window";
        enum MAXCOLORS = "maxColors";
        enum COLUMNS = "columns";
        enum ROWS = "rows";
        enum DELAYMS = "delayMs";
        enum HIGHSCORE = "highScore";
        enum X = "x";
        enum Y = "y";
        enum WIDTH = "width";
        enum HEIGHT = "height";

        enum DEF_MAXCOLORS = 4;
        enum DEF_COLUMNS = 9;
        enum DEF_ROWS = 9;
        enum DEF_DELAYMS = 250;
        enum DEF_HIGHSCORE = 0;
        enum DEF_WIDTH = 400;
        enum DEF_HEIGHT = 400;

        enum INVALID = -1;
        enum MIN_SIZE = 5;
        enum MAX_SIZE = 30;

        string filename;

        struct M {
            int maxColors = DEF_MAXCOLORS;
            int columns = DEF_COLUMNS;
            int rows = DEF_ROWS;
            int delayMs = DEF_DELAYMS;
            int highScore = DEF_HIGHSCORE;
            int x = INVALID;
            int y = INVALID;
            int width = DEF_WIDTH;
            int height = DEF_HEIGHT;
        }
        M m;
    }
}
