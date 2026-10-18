#pragma once

#include <array>
#include <cmath>
#include <cstring>
#include <vector>

// Locomotive wheel limits — from Excel sheets ALS/GEK/HID/GEA (+ CSR/QSY).
// Difference thresholds = sheet notes (status IF). Wear = shared ชก.4/0.27/184 / MR1-2246/1.
namespace wheel {

enum class Level { Empty, Ok, Shop, Scrap };

enum class Fleet { Als, Gek, Hid, Gea, Csr, Qsy };

struct Side {
    double tyre = 0;
    double tread = 0;
    double flange = 0;
    double root = 0;
    bool has_tyre = false;
    bool has_tread = false;
    bool has_flange = false;
    bool has_root = false;
};

struct Wheel {
    Side right;
    Side left;
};

struct Limits {
    Fleet fleet = Fleet::Als;
    const char* code = "ALS";
    const char* name_th = "Alstom";
    const char* name_en = "Alstom";
    // Diameter / thickness difference (mm) — status "ถึงพิกัด" when >= these
    double axle_mm = 0.5;
    double bogie_mm = 20.0;
    double loco_mm = 35.0;
    // Shared wear (mm). tyre_shop_mm = last-turn / shop band (0 = unused).
    double tyre_scrap_mm = 35.0;
    double tyre_shop_mm = 0.0;
    double tread_shop_mm = 3.0;
    double tread_scrap_mm = 7.0;
    double flange_shop_mm = 2.5;
    double flange_scrap_mm = 5.0;
    double root_ok_mm = 1.0;
    double root_scrap_mm = 2.0;
};

// Status thresholds from each sheet's notes (not the shared lookup row alone).
// GEK across-loco: note says 25.4 (table AI shows 24.4 — use note).
inline Limits limits_for(Fleet f) {
    Limits lim;
    lim.fleet = f;
    // shared wear defaults already set
    switch (f) {
    case Fleet::Als:
        lim.code = "ALS";
        lim.name_th = "Alstom";
        lim.name_en = "Alstom";
        lim.axle_mm = 0.5;
        lim.bogie_mm = 20.0;
        lim.loco_mm = 35.0;
        break;
    case Fleet::Gek:
        lim.code = "GEK";
        lim.name_th = "GE (GEK)";
        lim.name_en = "GE (GEK)";
        lim.axle_mm = 1.58;
        lim.bogie_mm = 25.4;
        lim.loco_mm = 25.4;
        break;
    case Fleet::Hid:
        lim.code = "HID";
        lim.name_th = "Hitachi";
        lim.name_en = "Hitachi";
        lim.axle_mm = 1.0;
        lim.bogie_mm = 7.0;
        lim.loco_mm = 20.0;
        break;
    case Fleet::Gea:
        lim.code = "GEA";
        lim.name_th = "GE (GEA)";
        lim.name_en = "GE (GEA)";
        lim.axle_mm = 2.38;
        lim.bogie_mm = 19.1;
        lim.loco_mm = 31.8;
        break;
    case Fleet::Csr:
        // มขร-R-006-2566 table 2–3 — solid wheel
        lim.code = "CSR";
        lim.name_th = "CSR";
        lim.name_en = "CSR";
        lim.axle_mm = 0.5;
        lim.bogie_mm = 1.0;
        lim.loco_mm = 1.0;
        lim.tyre_shop_mm = 31.5;
        lim.tyre_scrap_mm = 24.5;
        break;
    case Fleet::Qsy:
        lim.code = "QSY";
        lim.name_th = "QSY";
        lim.name_en = "QSY";
        lim.axle_mm = 0.5;
        lim.bogie_mm = 1.0;
        lim.loco_mm = 1.0;
        lim.tyre_shop_mm = 31.5;
        lim.tyre_scrap_mm = 24.5;
        break;
    }
    return lim;
}

inline Fleet fleet_from_code(const char* code) {
    if (!code) return Fleet::Als;
    if (std::strcmp(code, "GEK") == 0) return Fleet::Gek;
    if (std::strcmp(code, "HID") == 0) return Fleet::Hid;
    if (std::strcmp(code, "GEA") == 0) return Fleet::Gea;
    if (std::strcmp(code, "CSR") == 0) return Fleet::Csr;
    if (std::strcmp(code, "QSY") == 0) return Fleet::Qsy;
    return Fleet::Als;
}

// Diesel-electric running numbers (class bands).
// Sources: public Thai-railway roster / Wikipedia — GEK=UM12C, ALS=AD24C batch1,
// HID=8FA-36C, GEA=CM22-7i, CSR=SDA3, QSY=CDA5B1. AHK/ALD/ADD are other Alstom
// batches (not in this app). No complete public “ตัดบัญชี” list — accept in-band.
struct LocoBand {
    int lo = 0;
    int hi = 0;
    const char* code = "";
    const char* name = "";
    bool in_app = false;
    Fleet fleet = Fleet::Als;
};

inline const LocoBand* loco_bands(int& n) {
    static const LocoBand k[] = {
        {4001, 4050, "GEK", "GE UM12C", true, Fleet::Gek},
        {4101, 4154, "ALS", "Alstom ALS", true, Fleet::Als},
        {4201, 4230, "AHK", "Alstom AHK", false, Fleet::Als},
        {4301, 4309, "ALD", "Alstom ALD", false, Fleet::Als},
        {4401, 4420, "ADD", "Alstom ADD", false, Fleet::Als},
        {4501, 4522, "HID", "Hitachi HID", true, Fleet::Hid},
        {4523, 4560, "GEA", "GE GEA", true, Fleet::Gea},
        {5101, 5120, "CSR", "CSR SDA3", true, Fleet::Csr},
        {5201, 5250, "QSY", "CRRC QSY", true, Fleet::Qsy},
    };
    n = static_cast<int>(sizeof(k) / sizeof(k[0]));
    return k;
}

inline const LocoBand* find_loco_band(int num) {
    int n = 0;
    const LocoBand* b = loco_bands(n);
    for (int i = 0; i < n; ++i) {
        if (num >= b[i].lo && num <= b[i].hi) return &b[i];
    }
    return nullptr;
}

inline bool fleet_number_range(Fleet f, int& lo, int& hi) {
    int n = 0;
    const LocoBand* b = loco_bands(n);
    for (int i = 0; i < n; ++i) {
        if (b[i].in_app && b[i].fleet == f) {
            lo = b[i].lo;
            hi = b[i].hi;
            return true;
        }
    }
    return false;
}

enum class LocoCheck { Ok, Empty, BadDigits, WrongFleet, OtherClass, Unknown };

struct LocoCheckResult {
    LocoCheck status = LocoCheck::Empty;
    int number = 0;
    const LocoBand* band = nullptr;
};

inline LocoCheckResult check_loco_number(Fleet selected, const char* text) {
    LocoCheckResult r;
    if (!text || !*text) return r;
    int num = 0;
    int digits = 0;
    for (const char* p = text; *p; ++p) {
        if (*p >= '0' && *p <= '9') {
            num = num * 10 + (*p - '0');
            ++digits;
            if (digits > 6) {
                r.status = LocoCheck::BadDigits;
                return r;
            }
        } else if (*p == ' ' || *p == '-') {
            continue;
        } else {
            r.status = LocoCheck::BadDigits;
            return r;
        }
    }
    if (digits == 0) return r;
    r.number = num;
    r.band = find_loco_band(num);
    if (!r.band) {
        r.status = LocoCheck::Unknown;
        return r;
    }
    if (r.band->in_app && r.band->fleet == selected) {
        r.status = LocoCheck::Ok;
        return r;
    }
    if (r.band->in_app) {
        r.status = LocoCheck::WrongFleet;
        return r;
    }
    r.status = LocoCheck::OtherClass;
    return r;
}

inline Limits default_limits() { return limits_for(Fleet::Als); }

inline Level worse(Level a, Level b) {
    return static_cast<int>(a) >= static_cast<int>(b) ? a : b;
}

inline const char* level_th(Level lv) {
    switch (lv) {
    case Level::Empty: return "—";
    case Level::Ok: return "ปกติ";
    case Level::Shop: return "พิกัดซ่อม";
    case Level::Scrap: return "ถึงพิกัด";
    }
    return "—";
}

inline Level tyre_level(double mm, const Limits& lim) {
    if (mm <= lim.tyre_scrap_mm) return Level::Scrap;
    if (lim.tyre_shop_mm > 0.0 && mm <= lim.tyre_shop_mm) return Level::Shop;
    return Level::Ok;
}

inline Level wear_level(double mm, double shop, double scrap) {
    if (mm >= scrap) return Level::Scrap;
    if (mm >= shop) return Level::Shop;
    return Level::Ok;
}

inline Level root_level(double mm, const Limits& lim) {
    if (mm >= lim.root_scrap_mm) return Level::Scrap;
    if (mm > lim.root_ok_mm) return Level::Shop;
    return Level::Ok;
}

inline Level diff_level(double abs_diff, double limit) {
    if (abs_diff >= limit) return Level::Scrap;
    return Level::Ok;
}

struct DiffResult {
    double value_mm = 0;
    Level level = Level::Empty;
    bool valid = false;
};

struct SideStatus {
    Level tyre = Level::Empty;
    Level tread = Level::Empty;
    Level flange = Level::Empty;
    Level root = Level::Empty;
};

struct Report {
    std::array<Wheel, 6> wheels{};
    Limits limits = default_limits();
    std::array<DiffResult, 6> axle{};
    DiffResult bogie1{};
    DiffResult bogie2{};
    DiffResult loco{};
    std::array<SideStatus, 6> right_status{};
    std::array<SideStatus, 6> left_status{};
    Level worst = Level::Empty;
};

inline void collect_tyre(const Side& s, std::vector<double>& out) {
    if (s.has_tyre) out.push_back(s.tyre);
}

inline DiffResult max_min_diff(const std::vector<double>& vals, double limit) {
    DiffResult r;
    if (vals.size() < 2) return r;
    double lo = vals[0], hi = vals[0];
    for (double v : vals) {
        lo = std::min(lo, v);
        hi = std::max(hi, v);
    }
    r.valid = true;
    r.value_mm = hi - lo;
    r.level = diff_level(r.value_mm, limit);
    return r;
}

inline SideStatus eval_side(const Side& s, const Limits& lim) {
    SideStatus st;
    if (s.has_tyre) st.tyre = tyre_level(s.tyre, lim);
    if (s.has_tread) st.tread = wear_level(s.tread, lim.tread_shop_mm, lim.tread_scrap_mm);
    if (s.has_flange) st.flange = wear_level(s.flange, lim.flange_shop_mm, lim.flange_scrap_mm);
    if (s.has_root) st.root = root_level(s.root, lim);
    return st;
}

inline Report evaluate(const std::array<Wheel, 6>& wheels, Limits lim = default_limits()) {
    Report rep;
    rep.wheels = wheels;
    rep.limits = lim;
    rep.worst = Level::Empty;

    for (int i = 0; i < 6; ++i) {
        const Wheel& w = wheels[static_cast<size_t>(i)];
        if (w.right.has_tyre && w.left.has_tyre) {
            rep.axle[static_cast<size_t>(i)].valid = true;
            rep.axle[static_cast<size_t>(i)].value_mm = std::abs(w.right.tyre - w.left.tyre);
            rep.axle[static_cast<size_t>(i)].level =
                diff_level(rep.axle[static_cast<size_t>(i)].value_mm, lim.axle_mm);
            rep.worst = worse(rep.worst, rep.axle[static_cast<size_t>(i)].level);
        }
        rep.right_status[static_cast<size_t>(i)] = eval_side(w.right, lim);
        rep.left_status[static_cast<size_t>(i)] = eval_side(w.left, lim);
        for (Level lv : {rep.right_status[static_cast<size_t>(i)].tyre, rep.right_status[static_cast<size_t>(i)].tread,
                         rep.right_status[static_cast<size_t>(i)].flange, rep.right_status[static_cast<size_t>(i)].root,
                         rep.left_status[static_cast<size_t>(i)].tyre, rep.left_status[static_cast<size_t>(i)].tread,
                         rep.left_status[static_cast<size_t>(i)].flange, rep.left_status[static_cast<size_t>(i)].root}) {
            if (lv != Level::Empty) rep.worst = worse(rep.worst, lv);
        }
    }

    std::vector<double> b1, b2, all;
    for (int i = 0; i < 3; ++i) {
        collect_tyre(wheels[static_cast<size_t>(i)].right, b1);
        collect_tyre(wheels[static_cast<size_t>(i)].left, b1);
    }
    for (int i = 3; i < 6; ++i) {
        collect_tyre(wheels[static_cast<size_t>(i)].right, b2);
        collect_tyre(wheels[static_cast<size_t>(i)].left, b2);
    }
    all = b1;
    all.insert(all.end(), b2.begin(), b2.end());

    rep.bogie1 = max_min_diff(b1, lim.bogie_mm);
    rep.bogie2 = max_min_diff(b2, lim.bogie_mm);
    rep.loco = max_min_diff(all, lim.loco_mm);
    if (rep.bogie1.valid) rep.worst = worse(rep.worst, rep.bogie1.level);
    if (rep.bogie2.valid) rep.worst = worse(rep.worst, rep.bogie2.level);
    if (rep.loco.valid) rep.worst = worse(rep.worst, rep.loco.level);
    return rep;
}

inline constexpr double kInchPerMm = 1.0 / 25.4;
inline constexpr double kMmPerInch = 25.4;

inline double to_display(double mm, bool inches) { return inches ? mm * kInchPerMm : mm; }
inline double from_display(double v, bool inches) { return inches ? v * kMmPerInch : v; }

}  // namespace wheel
