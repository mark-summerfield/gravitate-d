// Copyright © 2020 Mark Summerfield. All rights reserved.

int maxColors = 4;
int columns = 9;
int rows = 9;
int delayMs = 250;
int highScore = 0;
int x = 0;
int y = 0;
int width = 400;
int height = 400;

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

    string filename;
}

void initialize(string applicationId) {
    import glib.Util: gutil = Util;
    import std.array: replace;
    import std.path: buildPath, dirSeparator;

    filename = buildPath(gutil.getUserConfigDir,
                         applicationId.replace('.', dirSeparator) ~ ".ini");
    load();
}

void load() {
    assert(filename.length);

    import glib.KeyFile: KeyFile;

    auto keyFile = new KeyFile;
    if (!keyFile.loadFromFile) {
        import std.stdio: stderr;
        stderr.writeln("failed to load config");
        return;
    }
    int n;
    n = keyFile.getInteger(BOARD, MAXCOLORS);
    // TODO check if error & if ok set
    n = keyFile.getInteger(BOARD, COLUMNS);
    n = keyFile.getInteger(BOARD, ROWS);
    n = keyFile.getInteger(BOARD, DELAYMS);
    n = keyFile.getInteger(BOARD, HIGHSCORE);
    n = keyFile.getInteger(WINDOW, X);
    n = keyFile.getInteger(WINDOW, Y);
    n = keyFile.getInteger(WINDOW, WIDTH);
    n = keyFile.getInteger(WINDOW, HEIGHT);
}

void save() {
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
            return;
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
    }
}
