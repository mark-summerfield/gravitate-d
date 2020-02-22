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

private string filename;

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
    // TODO load & update or use defaults if no .ini file found
import std.stdio: writeln; writeln("TODO config.load ", filename); // TODO
}

void save() {
    assert(filename.length);

    import std.file: exists, FileException, mkdirRecurse;
    import std.path: dirName;

    immutable path = dirName(filename);
    if (!path.exists)
        try {
            mkdirRecurse(path);
        } catch (FileException err) {
            import std.stdio: stderr;
            stderr.writefln("failed to save config: %s", err);
            return;
        }
    // TODO save config & highScore

import std.stdio: writeln; writeln("TODO config.save ", filename); // TODO
}
