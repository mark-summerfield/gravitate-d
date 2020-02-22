// Copyright © 2020 Mark Summerfield. All rights reserved.

struct Config {
    import color: COLORS;
    import glib.KeyFile: KeyFile;
    import std.algorithm: clamp;
    import std.conv: to;

    this(string applicationId) {
        import glib.Util: gutil = Util;
        import std.array: replace;
        import std.path: buildPath, dirSeparator;

        filename = buildPath(gutil.getUserConfigDir,
                             applicationId.replace('.',
                                                   dirSeparator) ~ ".ini");
        load();
    }

    int maxColors() const { return _maxColors; }

    void maxColors(const int maxColors) {
        _maxColors = clamp(maxColors, 2, COLORS.length.to!int);
    }

    int columns() const { return _columns; }

    void columns(const int columns) {
        _columns = clamp(columns, MIN_SIZE, MAX_SIZE);
    }

    int rows() const { return _rows; }

    void rows(const int rows) {
        _rows = clamp(rows, MIN_SIZE, MAX_SIZE);
    }

    int delayMs() const { return _delayMs; }

    void delayMs(const int delayMs) {
        _delayMs = clamp(delayMs, 0, 1000);
    }

    int highScore() const { return _highScore; }

    void highScore(const int highScore) {
        _highScore = clamp(highScore, 0, int.max);
    }

    int x() const { return _x; }

    void x(const int x) {
        _x = x;
    }

    int y() const { return _y; }

    void y(const int y) {
        _y = y;
    }

    int width() const { return _width; }

    void width(const int width) {
        _width = clamp(width, 200, 2000);
    }

    int height() const { return _height; }

    void height(const int height) {
        _height = clamp(height, 200, 2000);
    }

    private void load() {
        assert(filename.length);

        import glib.c.types: GKeyFileFlags;

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
        x(get(keyFile, WINDOW, X, DEF_X));
        y(get(keyFile, WINDOW, Y, DEF_Y));
        width(get(keyFile, WINDOW, WIDTH, DEF_WIDTH));
        height(get(keyFile, WINDOW, HEIGHT, DEF_HEIGHT));
    }

    // Can easily overload by distingishing on the type of defaultValue
    private int get(ref KeyFile keyFile, string group, string key,
                    const int defaultValue) {
        auto value = keyFile.getValue(group, key);
        if (value !is null) {
            import std.conv: ConvException;
            try {
                return value.to!int;
            } catch (ConvException) {
                // ignore and return default
            }
        }
        return defaultValue;
    }

    bool save() {
        assert(filename.length);

        import glib.KeyFile: KeyFile;
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
        enum DEF_X = 0;
        enum DEF_Y = 0;
        enum DEF_WIDTH = 400;
        enum DEF_HEIGHT = 400;

        enum MIN_SIZE = 5;
        enum MAX_SIZE = 30;

        string filename;
        int _maxColors = DEF_MAXCOLORS;
        int _columns = DEF_COLUMNS;
        int _rows = DEF_ROWS;
        int _delayMs = DEF_DELAYMS;
        int _highScore = DEF_HIGHSCORE;
        int _x = DEF_X;
        int _y = DEF_Y;
        int _width = DEF_WIDTH;
        int _height = DEF_HEIGHT;
    }
}
