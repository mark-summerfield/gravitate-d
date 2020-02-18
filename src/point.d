// Copyright © 2020 Mark Summerfield. All rights reserved.

struct Point {
    enum INVALID = -1;

    int x = INVALID;
    int y = INVALID;

    bool isValid() {
        return x != INVALID && y != INVALID;
    }
}
