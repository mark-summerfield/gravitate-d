// Copyright © 2020 Mark Summerfield. All rights reserved.

struct Color {
    import std.typecons: Tuple;

    alias Rgb = Tuple!(double, "red", double, "green", double, "blue");
    alias Pair = Tuple!(Color, "light", Color, "dark");

    enum BACKGROUND = Color(0xFF, 0xFE, 0xE0);
    enum FOCUS_RECT = Color(0xF, 0xF, 0xF);

    private {
        enum INVALID = -1;

        int red = INVALID;
        int green = INVALID;
        int blue = INVALID;
    }

    bool isValid() const {
        return red > INVALID && green > INVALID && blue > INVALID;
    }

    Rgb toRgb() const {
        assert(isValid);
        return Rgb(red / 255.0, green / 255.0, blue / 255.0);
    }

    // least (0.0 1.0] most changed
    Color darker(const double luminosity=0.2) const {
        return morphed(-luminosity);
    }

    // least (0.0 1.0] most changed
    Color lighter(const double luminosity=0.5) const {
        return morphed(luminosity);
    }

    // luminosity: lighten = (0.0 1.0]; darken = (0.0 -1.0]
    private Color morphed(const double luminosity) const {
        assert(isValid);
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

    size_t toHash() const @safe nothrow {
        return typeid(red).getHash(&red) ^ typeid(green).getHash(&green) ^
               typeid(blue).getHash(&blue);
    }

    bool opEquals(const Color other) const @safe pure nothrow {
        return red == other.red && green == other.green &&
               blue == other.blue;
    }
}

immutable Color[Color] COLORS;

shared static this() {
    import std.exception: assumeUnique;

    Color[Color] colors;
    colors[Color(0x00, 0x00, 0x80)] = Color(0x99, 0x99, 0xF9);
    colors[Color(0x00, 0x80, 0x00)] = Color(0x99, 0xF9, 0x99);
    colors[Color(0x00, 0x80, 0x80)] = Color(0x99, 0xF9, 0xF9);
    colors[Color(0x80, 0x00, 0x00)] = Color(0xF9, 0x99, 0x99);
    colors[Color(0x80, 0x00, 0x80)] = Color(0xF9, 0x99, 0xF9);
    colors[Color(0x80, 0x80, 0x00)] = Color(0xF9, 0xF9, 0x99);
    colors[Color(0x80, 0x80, 0x80)] = Color(0xF9, 0xF9, 0xF9);
    colors.rehash;
    COLORS = assumeUnique(colors);
}
