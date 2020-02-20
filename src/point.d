// Copyright © 2020 Mark Summerfield. All rights reserved.

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
}
