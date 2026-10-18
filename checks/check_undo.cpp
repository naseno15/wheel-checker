#undef NDEBUG
#include "calc.h"

#include <array>
#include <cassert>
#include <cstdio>
#include <vector>

// Mirrors Bridge undo stack: clear must restore prior wheel values.
int main() {
    using Snap = std::array<wheel::Wheel, 6>;
    Snap cur{};
    cur[0].right = {.tyre = 72.0, .has_tyre = true};
    cur[0].left = {.tyre = 71.5, .has_tyre = true};

    std::vector<Snap> undo;
    std::vector<Snap> redo;
    auto push = [&] {
        undo.push_back(cur);
        redo.clear();
    };
    auto doUndo = [&] {
        assert(!undo.empty());
        redo.push_back(cur);
        cur = undo.back();
        undo.pop_back();
    };

    push();
    cur[0] = {};  // clear wheel 1
    assert(!cur[0].right.has_tyre);
    doUndo();
    assert(cur[0].right.has_tyre && cur[0].right.tyre == 72.0);
    assert(cur[0].left.tyre == 71.5);

    std::puts("check_undo: ok");
    return 0;
}
