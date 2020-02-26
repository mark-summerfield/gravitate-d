// Copyright © 2020 Mark Summerfield. All rights reserved.
module qtrac.gravitate.point;

struct Point {
    private enum INVALID = -1;

    int x = INVALID;
    int y = INVALID;

    bool isValid() const {
        return x > INVALID && y > INVALID;
    }

    void clear() {
        x = INVALID;
        y = INVALID;
    }

    size_t toHash() const @safe nothrow {
        return typeid(x).getHash(&x) ^ typeid(y).getHash(&y);
    }

    bool opEquals(const Point other) const @safe pure nothrow {
        return x == other.x && y == other.y;
    }

    int opCmp(ref const Point other) const {
        return (x == other.x) ? y - other.y : x - other.x;
    }
}
