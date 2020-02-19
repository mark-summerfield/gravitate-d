// Copyright © 2020 Mark Summerfield. All rights reserved.

struct Color {
    import std.typecons: Tuple;

    alias Rgb = Tuple!(double, "red", double, "green", double, "blue");
    alias Pair = Tuple!(Color, "light", Color, "dark");

    private int red;
    private int green;
    private int blue;

    static Color invalid() {
        return Color(-1, -1, -1);
    }

    bool isValid() const {
        return red >= 0 && green >= 0 && blue >= 0;
    }

    Rgb toRgb() const {
        return Rgb(red / 255.0, green / 255.0, blue / 255.0);
    }

    /// luminosity: lighten = (0.0 1.0]; darken = (0.0 -1.0]
    Color morphed(double luminosity) const {
        import std.conv: to;
        import std.math: fmax, fmin, round;

        int r = round(fmin(fmax(0, red + (red * luminosity)), 0xFF)).to!int;
        int g = round(fmin(fmax(0, green + (green * luminosity)), 0xFF)).to!int;
        int b = round(fmin(fmax(0, blue + (blue * luminosity)), 0xFF)).to!int;
        return Color(r, g, b);
    }
}

enum ACTIVE_BG_COLOR = Color(0xFF, 0xFE, 0xE0);
enum INACTIVE_BG_COLOR = Color(0xF0, 0xF0, 0xF0);
enum ACTIVE_FOCUS_RECT_COLOR = Color(0, 0, 0); // black
enum INACTIVE_FOCUS_RECT_COLOR = Color(0x7F, 0x7F, 0x7F); // gray
enum INVALID_COLOR = Color.invalid();
enum GAME_COLORS = [
        Color(0x64, 0x95, 0xED),
        Color(0x46, 0x82, 0xB4),
        Color(0x00, 0xCE, 0xD1),
        Color(0x2E, 0x8B, 0x57),
        Color(0x6B, 0x8E, 0x23),
        Color(0xBD, 0xB7, 0x6B),
        Color(0xBC, 0x8F, 0x8F),
        Color(0xCD, 0x5C, 0x5C),
        Color(0xDD, 0xA0, 0xDD),
        Color(0x93, 0x70, 0xDB),
        Color(0xEE, 0xC9, 0x00),
        Color(0x7F, 0x7F, 0x7F),
        Color(0x38, 0x8E, 0x8E),
        Color(0x71, 0xC6, 0x71),
        Color(0x8E, 0x38, 0x8E),
        Color(0xFF, 0x82, 0xAB),
        Color(0xFF, 0xA5, 0x00),
    ];
