// Copyright © 2020 Mark Summerfield. All rights reserved.

struct Color {
    import std.typecons: Tuple;

    alias Rgb = Tuple!(double, "red", double, "green", double, "blue");
    alias Pair = Tuple!(Color, "light", Color, "dark");

    enum ACTIVE_BG = Color(0xFF, 0xFE, 0xE0);
    enum INACTIVE_BG = Color(0xF0, 0xF0, 0xF0);
    enum ACTIVE_FOCUS_RECT = Color(0xF, 0xF, 0xF); // almost black
    enum INACTIVE_FOCUS_RECT = Color(0x7F, 0x7F, 0x7F); // gray
    enum INVALID = -1;
    enum DARKEN = -0.5;
    enum LIGHTEN = 0.5;

    private int red = INVALID;
    private int green = INVALID;
    private int blue = INVALID;

    bool isValid() const {
        return red > INVALID && green > INVALID && blue > INVALID;
    }

    Rgb toRgb() const {
        assert(isValid());
        return Rgb(red / 255.0, green / 255.0, blue / 255.0);
    }

    /// luminosity: lighten = (0.0 1.0]; darken = (0.0 -1.0]
    Color morphed(double luminosity) const {
        assert(isValid());
        import std.conv: to;
        import std.math: fmax, fmin, round;

        immutable r = round(fmin(fmax(0, red + (red * luminosity)),
                                      0xFF)).to!int;
        immutable g = round(fmin(fmax(0, green + (green * luminosity)),
                                      0xFF)).to!int;
        immutable b = round(fmin(fmax(0, blue + (blue * luminosity)),
                                      0xFF)).to!int;
        return Color(r, g, b);
    }

    size_t toHash() const @safe pure nothrow {
        return red ^ green ^ blue;
    }

    bool opEquals(const Color other) const @safe pure nothrow {
        return red == other.red && green == other.green &&
               blue == other.blue;
    }
}

immutable Color[Color] GAME_COLORS;

shared static this() {
    import std.exception: assumeUnique;

    Color[Color] temp;
    temp[Color(0x00, 0x00, 0x80)] = Color(0x99, 0x99, 0xF9);
    temp[Color(0x00, 0x80, 0x00)] = Color(0x99, 0xF9, 0x99);
    temp[Color(0x00, 0x80, 0x80)] = Color(0x99, 0xF9, 0xF9);
    temp[Color(0x80, 0x00, 0x00)] = Color(0xF9, 0x99, 0x99);
    temp[Color(0x80, 0x00, 0x80)] = Color(0xF9, 0x99, 0xF9);
    temp[Color(0x80, 0x80, 0x00)] = Color(0xF9, 0xF9, 0x99);
    temp[Color(0x80, 0x80, 0x80)] = Color(0xF9, 0xF9, 0xF9);
    temp.rehash;
    GAME_COLORS = assumeUnique(temp);
}
