#undef NDEBUG
#include "calc.h"

#include <cassert>
#include <cmath>
#include <cstdio>

int main() {
    using namespace wheel;

    std::array<Wheel, 6> w{};
    w[0].right = {.tyre = 72, .has_tyre = true};
    w[0].left = {.tyre = 71.4, .has_tyre = true};  // 0.6
    auto r = evaluate(w, limits_for(Fleet::Als));
    assert(r.axle[0].level == Level::Scrap);

    r = evaluate(w, limits_for(Fleet::Hid));
    assert(r.axle[0].level == Level::Ok);  // 0.6 < 1.0

    w[0].left.tyre = 70.9;  // 1.1
    r = evaluate(w, limits_for(Fleet::Hid));
    assert(r.axle[0].level == Level::Scrap);

    w = {};
    w[0].right = {.tyre = 40, .has_tyre = true};
    w[0].left = {.tyre = 40, .has_tyre = true};
    w[1].right = {.tyre = 60, .has_tyre = true};
    w[1].left = {.tyre = 60, .has_tyre = true};
    w[2].right = {.tyre = 60, .has_tyre = true};
    w[2].left = {.tyre = 60, .has_tyre = true};
    r = evaluate(w, limits_for(Fleet::Gek));
    assert(std::abs(r.bogie1.value_mm - 20.0) < 1e-9);
    assert(r.bogie1.level == Level::Ok);
    r = evaluate(w, limits_for(Fleet::Als));
    assert(r.bogie1.level == Level::Scrap);

    assert(std::abs(limits_for(Fleet::Gea).axle_mm - 2.38) < 1e-9);
    assert(std::abs(limits_for(Fleet::Gea).loco_mm - 31.8) < 1e-9);
    assert(fleet_from_code("HID") == Fleet::Hid);

    // CSR / QSY — มขร-R-006-2566
    const Limits csr = limits_for(Fleet::Csr);
    assert(csr.axle_mm == 0.5 && csr.bogie_mm == 1.0 && csr.loco_mm == 1.0);
    assert(csr.tyre_scrap_mm == 24.5 && csr.tyre_shop_mm == 31.5);
    assert(fleet_from_code("QSY") == Fleet::Qsy);

    w = {};
    w[0].right = {.tyre = 28.0, .has_tyre = true};  // between shop and scrap
    r = evaluate(w, limits_for(Fleet::Csr));
    assert(r.right_status[0].tyre == Level::Shop);
    w[0].right.tyre = 24.5;
    r = evaluate(w, limits_for(Fleet::Qsy));
    assert(r.right_status[0].tyre == Level::Scrap);

    w[0].right.tyre = 50;
    w[0].left = {.tyre = 49.0, .has_tyre = true};  // diff 1.0
    r = evaluate(w, limits_for(Fleet::Csr));
    assert(r.axle[0].level == Level::Scrap);  // >= 0.5 axle… wait 1.0 >= 0.5 scrap
    // bogie needs 2+ wheels — axle scrap is enough
    assert(r.axle[0].value_mm == 1.0);

    // Loco roster bands
    auto ok = check_loco_number(Fleet::Als, "4101");
    assert(ok.status == LocoCheck::Ok && ok.number == 4101);
    auto wrong = check_loco_number(Fleet::Als, "4501");
    assert(wrong.status == LocoCheck::WrongFleet);
    auto gek = check_loco_number(Fleet::Gek, "4001");
    assert(gek.status == LocoCheck::Ok);
    auto ahk = check_loco_number(Fleet::Als, "4201");
    assert(ahk.status == LocoCheck::OtherClass);
    auto qsy = check_loco_number(Fleet::Qsy, "5201");
    assert(qsy.status == LocoCheck::Ok);
    auto unknown = check_loco_number(Fleet::Als, "9999");
    assert(unknown.status == LocoCheck::Unknown);

    std::puts("check_calc: ok");
    return 0;
}
