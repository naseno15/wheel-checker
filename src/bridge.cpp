#include "bridge.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QFont>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QUrl>
#include <algorithm>
#include <cstdio>

namespace {

QString res(const char* path) {
    return QStringLiteral("qrc:/wheel/") + QLatin1String(path);
}

QString tone_of(wheel::Level lv) {
    switch (lv) {
    case wheel::Level::Empty: return QStringLiteral("empty");
    case wheel::Level::Ok: return QStringLiteral("ok");
    case wheel::Level::Shop: return QStringLiteral("warn");
    case wheel::Level::Scrap: return QStringLiteral("bad");
    }
    return QStringLiteral("empty");
}

QString fmt(double mm, bool inches) {
    const double v = wheel::to_display(mm, inches);
    return QString::number(v, 'f', 3);  // field + results: always 3 dp (50 → 50.000)
}

QString load_family(const QString& path, const QString& fallback) {
    const int id = QFontDatabase::addApplicationFont(path);
    if (id < 0) return fallback;
    const QStringList fams = QFontDatabase::applicationFontFamilies(id);
    return fams.isEmpty() ? fallback : fams.front();
}

struct Glyph {
    const char* name;
    char16_t code;
};

const Glyph kGlyphs[] = {
    {"home", 0xe88a},
    {"edit", 0xe3c9},
    {"fact_check", 0xf0c5},
    {"menu_book", 0xea19},
    {"settings", 0xe8b8},
    {"check", 0xe5ca},
    {"warning", 0xe002},
    {"error", 0xe000},
    {"dark_mode", 0xe51c},
    {"light_mode", 0xe518},
    {"straighten", 0xe41c},
    {"directions_railway", 0xe535},
    {"build", 0xe869},
    {"info", 0xe88e},
    {"clear", 0xe14c},
    {"save", 0xe161},
    {"chevron_right", 0xe5cc},
    {"arrow_back", 0xe5c4},
    {"expand_more", 0xe5cf},
    {"history", 0xe889},
    {"language", 0xe894},
    {"delete", 0xe872},
};

struct TrPair {
    const char* key;
    const char* th;
    const char* en;
};

const TrPair kTr[] = {
    {"app_title", "พิกัดล้อ", "Wheel Limits"},
    {"app_sub", "ออฟไลน์ - งานสนาม", "Offline - Field work"},
    {"home", "หน้าหลัก", "Home"},
    {"entry", "กรอก", "Entry"},
    {"result", "ผล", "Result"},
    {"settings", "ตั้งค่า", "Settings"},
    {"guide", "ไกด์พิกัด", "Limits guide"},
    {"choose_task", "เริ่มงานสนาม", "Start field work"},
    {"home_hint", "เลือกเมนูด้านล่าง · ปุ่มใหญ่กดง่ายในโรงซ่อม", "Pick a menu below · large tap targets for the shop"},
    {"enter_wheels", "กรอกค่าล้อ", "Enter wheel data"},
    {"enter_sub", "เลือกชนิด → เลขรถ → กรอกค่า", "Fleet → number → values"},
    {"result_sub", "สรุปงานที่กำลังกรอก", "Current session summary"},
    {"guide_sub", "เกณฑ์ตามชนิดรถจักร", "Limits by locomotive class"},
    {"settings_sub", "ธีม · หน่วย · ภาษา", "Theme · units · language"},
    {"home_badge", "ออฟไลน์พร้อมใช้", "Ready offline"},
    {"pick_fleet", "เลือกชนิดรถจักร", "Choose locomotive type"},
    {"pick_fleet_hint", "กดรุ่นรถจักรครั้งเดียว ไปกรอกเลขได้เลย", "Tap a fleet once to enter its number"},
    {"pick_loco", "ใส่เลขรถจักร", "Enter loco number"},
    {"pick_loco_hint", "พิมพ์เลขแล้วกดถัดไปได้เลย ไม่ต้องกดนอกช่อง", "Type the number, then Next — no need to tap away"},
    {"loco_range", "เลขรุ่นนี้ %1–%2", "This class: %1–%2"},
    {"loco_ok", "ตรงรุ่น %1", "Matches %1"},
    {"loco_bad_digits", "ใส่เฉพาะตัวเลขหมายเลขรถจักร", "Digits only for loco number"},
    {"loco_wrong_fleet", "เลข %1 เป็นรุ่น %2 ไม่ใช่ %3", "%1 is %2, not %3"},
    {"loco_other_class", "เลข %1 เป็น %2 — ไม่ใช่รุ่นที่เลือก", "%1 is %2 — not the selected class"},
    {"loco_unknown", "ไม่พบเลข %1 ในบัญชีรุ่นที่รองรับ", "%1 is not in the supported class bands"},
    {"loco_note_retired", "ตรวจตามช่วงเลขรุ่น (ไม่มีรายชื่อตัดบัญชีสาธารณะครบ)", "Checked by class number band (no full public withdrawn list)"},
    {"axle_pick", "เพลา", "Axle"},
    {"next", "ถัดไป", "Next"},
    {"need_fleet", "เลือกชนิดรถก่อน", "Pick a fleet first"},
    {"need_loco_num", "ใส่เลขรถจักรก่อนกรอกค่า", "Enter loco number before measuring"},
    {"fleet_als", "Alstom", "Alstom"},
    {"fleet_gek", "GEK", "GEK"},
    {"fleet_hid", "Hitachi", "Hitachi"},
    {"fleet_gea", "GEA", "GEA"},
    {"fleet_csr", "CSR", "CSR"},
    {"fleet_qsy", "QSY", "QSY"},
    {"fleet_als_sub", "0.5 / 20 / 35", "0.5 / 20 / 35"},
    {"fleet_gek_sub", "1.58 / 25.4 / 25.4", "1.58 / 25.4 / 25.4"},
    {"fleet_hid_sub", "1 / 7 / 20", "1 / 7 / 20"},
    {"fleet_gea_sub", "2.38 / 19.1 / 31.8", "2.38 / 19.1 / 31.8"},
    {"fleet_csr_sub", "0.5 / 1 / 1", "0.5 / 1 / 1"},
    {"fleet_qsy_sub", "0.5 / 1 / 1", "0.5 / 1 / 1"},
    {"back", "กลับ", "Back"},
    {"summary_of", "ผลสรุป", "Summary"},
    {"tyre_limits", "ความหนาล้อ", "Wheel thickness"},
    {"tyre_shop_scrap", "กลึงครั้งสุดท้าย / เลิกใช้", "Last turn / scrap"},
    {"bogie", "แคร่", "Bogie"},
    {"wheel", "ล้อ", "Wheel"},
    {"entry_hint", "หัวช่อง = ค่าพิกัด · สีช่อง = สถานะ (เขียว/เหลือง/แดง)", "Header = limits · field colour = status"},
    {"diagram_hint", "แตะล้อใต้โครงรถเพื่อเลือกเพลา", "Tap a wheel under the frame to pick an axle"},
    {"fuel_tank", "ถังน้ำมัน", "Fuel"},
    {"tyre", "ปลอกล้อ", "Tyre thickness"},
    {"tread", "พื้นล้อ", "Tread wear"},
    {"flange", "บังใบ", "Flange wear"},
    {"root", "โคนบังใบ", "Flange root"},
    {"lim_tyre", "หนา > %1  ·  ต่างเพลา < %2", "thick > %1  ·  axle Δ < %2"},
    {"lim_tyre_shop", "ซ่อม ≤ %1  ·  เลิกใช้ ≤ %2  ·  Δเพลา < %3", "shop ≤ %1  ·  scrap ≤ %2  ·  axle Δ < %3"},
    {"lim_wear", "ซ่อม ≥ %1  ·  เลิกใช้ ≥ %2", "shop ≥ %1  ·  scrap ≥ %2"},
    {"lim_root", "ปกติ ≤ %1  ·  เลิกใช้ ≥ %2", "OK ≤ %1  ·  scrap ≥ %2"},
    {"right", "ขวา", "Right"},
    {"left", "ซ้าย", "Left"},
    {"clear_wheel", "ล้างล้อนี้", "Clear wheel"},
    {"next_axle", "ไปเพลาถัดไป", "Next axle"},
    {"see_result", "ดูผลสรุป", "See summary"},
    {"summary", "ผลสรุป", "Summary"},
    {"overall", "สถานะรวม", "Overall"},
    {"back_entry", "กลับไปกรอก", "Back to entry"},
    {"save_result", "บันทึกผล", "Save result"},
    {"loco_no", "เลขรถจักร", "Loco number"},
    {"loco_ph", "เช่น 4501", "e.g. 4501"},
    {"saved", "บันทึกแล้ว", "Saved"},
    {"need_loco", "กรอกเลขรถจักรก่อนบันทึก", "Enter loco number before saving"},
    {"save_page", "บันทึกผล", "Save result"},
    {"save_page_hint", "ใส่เลขรถจักรได้ หรือปล่อยว่าง ระบบตั้งชื่อตามวันเวลา", "Enter loco number, or leave blank to auto-name by date/time"},
    {"skip_auto", "ไม่ใส่ ใช้ชื่ออัตโนมัติ", "Skip - auto name"},
    {"confirm_save", "บันทึก", "Save"},
    {"auto_named", "ตั้งชื่ออัตโนมัติ", "Auto-named"},
    {"load_saved", "โหลดผลที่บันทึก", "Load saved result"},
    {"no_saved", "ยังไม่มีรายการบันทึก", "No saved records yet"},
    {"history", "ประวัติ", "History"},
    {"history_title", "ประวัติรถจักรที่บันทึก", "Saved locomotive history"},
    {"history_hint", "กดเลขรถเพื่อเปิดสถิติคันนั้นทันที", "Tap a loco to open its stats"},
    {"history_sub", "ดูผลย้อนหลังตามเลขรถ / วันที่", "Past results by loco or date"},
    {"sort_by", "เรียงตาม", "Sort by"},
    {"sort_modified", "แก้ไขล่าสุด", "Last edited"},
    {"sort_created", "วันที่สร้าง", "Created"},
    {"sort_loco", "เลขรถจักร", "Loco number"},
    {"created_at", "สร้าง", "Created"},
    {"modified_at", "แก้ไข", "Edited"},
    {"open_stats", "เปิดสถิติ", "Open stats"},
    {"delete_rec", "ลบ", "Delete"},
    {"guide_title", "ไกด์พิกัด", "Limits guide"},
    {"guide_hint", "แยกแท็บ ความต่าง / เลิกใช้ / การสึก", "Tabs: difference / scrap / wear"},
    {"badge_diff", "ความต่าง", "Difference"},
    {"badge_wear", "การสึก", "Wear"},
    {"badge_scrap", "เลิกใช้", "Scrap"},
    {"axle_same", "เพลาเดียวกัน", "Same axle"},
    {"bogie_same", "แคร่เดียวกัน", "Same bogie"},
    {"loco_diff", "ต่างแคร่ในคัน", "Across loco"},
    {"tyre_scrap", "ปลอกล้อ - เลิกใช้", "Tyre - scrap"},
    {"tread_limits", "พื้นล้อ", "Tread"},
    {"flange_limits", "บังใบ", "Flange"},
    {"root_limits", "โคนบังใบ", "Flange root"},
    {"shop_scrap", "ซ่อม / เลิกใช้", "Shop / scrap"},
    {"ok_scrap", "ปกติ / เลิกใช้", "OK / scrap"},
    {"settings_title", "ตั้งค่า", "Settings"},
    {"settings_hint", "สลับหน่วยและภาษาที่นี่  -  หน้ากรอกไม่ให้กดสลับ กันพลาดมือ", "Change unit and language here only"},
    {"theme", "ธีม", "Theme"},
    {"theme_hint", "พื้นหลังไล่สี อ่านง่ายทั้งกลางวัน/กลางคืน", "Soft gradients for day and night"},
    {"light", "สว่าง", "Light"},
    {"dark", "มืด", "Dark"},
    {"unit", "หน่วยความยาว", "Length unit"},
    {"unit_hint", "แสดงท้ายช่องกรอก", "Shown at end of each field"},
    {"mm", "มม.", "mm"},
    {"inch", "นิ้ว", "in"},
    {"btn_size", "ขนาดปุ่ม", "Button size"},
    {"btn_hint", "งานสนามแนะนำใหญ่", "Large recommended in the shop"},
    {"normal", "ปกติ", "Normal"},
    {"large", "ใหญ่", "Large"},
    {"language", "ภาษา", "Language"},
    {"lang_hint", "ไทย / English", "Thai / English"},
    {"clear_all", "ล้างข้อมูลทั้งหมด", "Clear all data"},
    {"no_data", "ยังไม่มีข้อมูล", "No data yet"},
    {"no_data_hint", "กรอกค่าที่หน้ากรอกก่อน", "Enter values on the Entry page first"},
    {"axle_of", "เพลา %1", "Axle %1"},
    {"diff_val", "ต่าง %1 %2", "Diff %1 %2"},
    {"grp_axle", "ความต่างเพลา (L/R)", "Axle difference (L/R)"},
    {"grp_bogie", "ความต่างแคร่", "Bogie difference"},
    {"grp_loco", "ความต่างทั้งคัน", "Loco difference"},
    {"grp_wear", "จุดที่ต้องดู", "Items to check"},
    {"filter_all", "ทั้งหมด", "All"},
    {"filter_by_status", "แยกตามหมวดซ่อม", "Filter by status"},
    {"guide_pick_fleet", "เลือกรุ่นเพื่อดูพิกัด", "Pick a class to view limits"},
    {"result_ok_n", "ปกติ %1", "OK %1"},
    {"result_warn_n", "ซ่อม %1", "Shop %1"},
    {"result_bad_n", "ถึงพิกัด %1", "Limit %1"},
    {"wear_val", "สึก %1 %2", "Wear %1 %2"},
    {"status_ok", "ปกติ", "OK"},
    {"status_shop", "พิกัดซ่อม", "Shop limit"},
    {"status_scrap", "ถึงพิกัด", "At limit"},
    {"guide_axle_note", "ต่างความหนาปลอก L/R", "L/R tyre thickness difference"},
    {"guide_bogie_note", "max − min ในแคร่", "max − min in bogie"},
    {"guide_loco_note", "max − min ทั้งคัน", "max − min across loco"},
    {"guide_tyre_note", "หนา ≤ ค่านี้ = เลิกใช้", "Thickness ≤ this = scrap"},
};

}  // namespace

Bridge::Bridge(QObject* parent) : QObject(parent) {
    QFontDatabase::addApplicationFont(QStringLiteral(":/wheel/fonts/MaterialIcons-Regular.ttf"));
    thai_family_ = load_family(QStringLiteral(":/wheel/fonts/NotoSansThaiLooped.ttf"),
                               QStringLiteral("Noto Sans Thai Looped"));
    latin_family_ = load_family(QStringLiteral(":/wheel/fonts/NotoSans-Regular.ttf"), QStringLiteral("Noto Sans"));
    font_ready_ = QFontDatabase::hasFamily(thai_family_);
    std::printf("wheel_font: thai=[%s] latin=[%s] ready=%d\n", qPrintable(thai_family_), qPrintable(latin_family_),
                font_ready_ ? 1 : 0);
    loadPrefs();
    refreshLocoCheck();
    recompute();
}

void Bridge::applyApplicationFont() const {
    // Qt does not treat "FamilyA, FamilyB" like CSS. Use setFamilies() fallback chain.
    QFont font(thai_family_);
    font.setFamilies({thai_family_, latin_family_, QStringLiteral("Segoe UI")});
    font.setStyleStrategy(QFont::PreferAntialias);
    font.setHintingPreference(QFont::PreferFullHinting);
    font.setPixelSize(14);
    QGuiApplication::setFont(font);
    QQuickWindow::setTextRenderType(QQuickWindow::QtTextRendering);
}

QString Bridge::t(const QString& key) const {
    const QByteArray k = key.toUtf8();
    for (const TrPair& p : kTr) {
        if (k == p.key) return lang_ == QLatin1String("en") ? QString::fromUtf8(p.en) : QString::fromUtf8(p.th);
    }
    return key;
}

QString Bridge::levelLabel(wheel::Level lv) const {
    switch (lv) {
    case wheel::Level::Empty: return QStringLiteral("—");
    case wheel::Level::Ok: return t(QStringLiteral("status_ok"));
    case wheel::Level::Shop: return t(QStringLiteral("status_shop"));
    case wheel::Level::Scrap: return t(QStringLiteral("status_scrap"));
    }
    return QStringLiteral("—");
}

QString Bridge::unitLabel() const {
    return inches_ ? t(QStringLiteral("inch")) : t(QStringLiteral("mm"));
}

void Bridge::setDark(bool v) {
    if (dark_ == v) return;
    dark_ = v;
    emit darkChanged();
    savePrefs();
}

void Bridge::setInches(bool v) {
    if (inches_ == v) return;
    inches_ = v;
    emit inchesChanged();
    emit unitChanged();
    emit guideChanged();
    emit fieldsChanged();
    recompute();
    savePrefs();
}

void Bridge::setLargeControls(bool v) {
    if (large_ == v) return;
    large_ = v;
    emit largeControlsChanged();
    savePrefs();
}

void Bridge::setLang(const QString& v) {
    const QString n = (v == QLatin1String("en")) ? QStringLiteral("en") : QStringLiteral("th");
    if (lang_ == n) return;
    lang_ = n;
    refreshLocoCheck();
    emit langChanged();
    emit unitChanged();
    emit guideChanged();
    emit fleetChanged();
    emit locoNumberChanged();
    emit sessionChanged();
    recompute();
    savePrefs();
}

void Bridge::setPage(const QString& p) {
    if (page_ == p) return;
    page_ = p;
    emit pageChanged();
}

QString Bridge::fleetCode() const { return QString::fromUtf8(currentLimits().code); }

void Bridge::setFleetCode(const QString& code) {
    const wheel::Fleet f = wheel::fleet_from_code(code.toUtf8().constData());
    if (fleet_ == f && fleet_picked_) return;
    const bool changed = fleet_ != f;
    fleet_ = f;
    fleet_picked_ = true;
    guide_fleet_ = f;
    refreshLocoCheck();
    if (changed) {
        wheels_ = {};
        bogie_ = 0;
        wheel_ = 0;
        emit bogieChanged();
        emit wheelChanged();
        emit fieldsChanged();
    }
    emit fleetChanged();
    emit locoNumberChanged();
    emit sessionChanged();
    emit guideChanged();
    recompute();
    savePrefs();
}

QString Bridge::guideFleetCode() const {
    return QString::fromUtf8(wheel::limits_for(guide_fleet_).code);
}

void Bridge::setGuideFleetCode(const QString& code) {
    const wheel::Fleet f = wheel::fleet_from_code(code.toUtf8().constData());
    if (guide_fleet_ == f) return;
    guide_fleet_ = f;
    emit guideChanged();
}

QString Bridge::guideFleetName() const {
    const wheel::Limits lim = wheel::limits_for(guide_fleet_);
    return lang_ == QLatin1String("en") ? QString::fromUtf8(lim.name_en) : QString::fromUtf8(lim.name_th);
}

QString Bridge::fleetName() const {
    const wheel::Limits lim = currentLimits();
    return lang_ == QLatin1String("en") ? QString::fromUtf8(lim.name_en) : QString::fromUtf8(lim.name_th);
}

QString Bridge::fleetHeadline() const {
    // Band name + running number once the loco field matches a roster band.
    const wheel::LocoCheckResult r = wheel::check_loco_number(fleet_, loco_number_.toUtf8().constData());
    if (r.band && (r.status == wheel::LocoCheck::Ok || r.status == wheel::LocoCheck::OtherClass
                   || r.status == wheel::LocoCheck::WrongFleet)) {
        QString out = QString::fromUtf8(r.band->name);
        out += QStringLiteral("  ·  ");
        out += QString::fromUtf8(r.band->code);
        if (!loco_number_.isEmpty())
            out += QLatin1Char(' ') + loco_number_;
        return out;
    }
    return fleetName() + QStringLiteral("  ·  ") + fleetCode();
}

QString Bridge::tyreLabel() const {
    if (fleet_ == wheel::Fleet::Csr || fleet_ == wheel::Fleet::Qsy)
        return t(QStringLiteral("tyre_limits"));
    return t(QStringLiteral("tyre"));
}

QString Bridge::sessionTitle() const {
    const wheel::LocoCheckResult r = wheel::check_loco_number(fleet_, loco_number_.toUtf8().constData());
    if (r.band && (r.status == wheel::LocoCheck::Ok || r.status == wheel::LocoCheck::OtherClass
                   || r.status == wheel::LocoCheck::WrongFleet)) {
        QString s = QString::fromUtf8(r.band->name) + QStringLiteral(" (")
                    + QString::fromUtf8(r.band->code) + QLatin1Char(')');
        if (!loco_number_.isEmpty()) s += QStringLiteral(" - ") + loco_number_;
        return s;
    }
    QString s = fleetName() + QStringLiteral(" (") + fleetCode() + QLatin1Char(')');
    if (!loco_number_.isEmpty()) s += QStringLiteral(" - ") + loco_number_;
    return s;
}

QString Bridge::locoRangeHint() const {
    int lo = 0, hi = 0;
    if (!wheel::fleet_number_range(fleet_, lo, hi)) return {};
    return t(QStringLiteral("loco_range")).arg(lo).arg(hi);
}

void Bridge::refreshLocoCheck() {
    const wheel::LocoCheckResult r = wheel::check_loco_number(fleet_, loco_number_.toUtf8().constData());
    QString msg;
    QString tone = QStringLiteral("empty");
    switch (r.status) {
    case wheel::LocoCheck::Empty:
        msg = locoRangeHint() + QStringLiteral("  ·  ") + t(QStringLiteral("loco_note_retired"));
        tone = QStringLiteral("empty");
        break;
    case wheel::LocoCheck::Ok:
        msg = t(QStringLiteral("loco_ok")).arg(QString::fromUtf8(r.band->code));
        tone = QStringLiteral("ok");
        break;
    case wheel::LocoCheck::BadDigits:
        msg = t(QStringLiteral("loco_bad_digits"));
        tone = QStringLiteral("bad");
        break;
    case wheel::LocoCheck::WrongFleet:
        msg = t(QStringLiteral("loco_wrong_fleet"))
                  .arg(r.number)
                  .arg(QString::fromUtf8(r.band->code))
                  .arg(fleetCode());
        tone = QStringLiteral("bad");
        break;
    case wheel::LocoCheck::OtherClass:
        msg = t(QStringLiteral("loco_other_class"))
                  .arg(r.number)
                  .arg(QString::fromUtf8(r.band->name));
        tone = QStringLiteral("warn");
        break;
    case wheel::LocoCheck::Unknown:
        msg = t(QStringLiteral("loco_unknown")).arg(r.number);
        tone = QStringLiteral("bad");
        break;
    }
    loco_check_msg_ = msg;
    loco_check_tone_ = tone;
}

void Bridge::startWizard() {
    page_ = QStringLiteral("fleet");
    emit pageChanged();
}

void Bridge::goEntryNav() {
    if (!fleet_picked_) {
        page_ = QStringLiteral("fleet");
    } else if (loco_number_.trimmed().isEmpty()) {
        page_ = QStringLiteral("loco");
    } else {
        page_ = QStringLiteral("entry");
    }
    emit pageChanged();
}

void Bridge::confirmFleet() {
    if (!fleet_picked_) {
        fleet_picked_ = true;
        emit fleetChanged();
    }
    page_ = QStringLiteral("loco");
    emit pageChanged();
}

void Bridge::confirmLoco() {
    refreshLocoCheck();
    if (loco_number_.trimmed().isEmpty()) {
        save_hint_ = t(QStringLiteral("need_loco_num"));
        emit savedChanged();
        return;
    }
    if (loco_check_tone_ != QLatin1String("ok")) {
        save_hint_ = loco_check_msg_;
        emit savedChanged();
        return;
    }
    save_hint_.clear();
    emit savedChanged();
    page_ = QStringLiteral("entry");
    emit pageChanged();
    emit sessionChanged();
}

void Bridge::setBogie(int v) {
    v = v < 0 ? 0 : (v > 1 ? 1 : v);
    if (bogie_ == v) return;
    bogie_ = v;
    const int base = bogie_ * 3;
    if (wheel_ < base || wheel_ >= base + 3) wheel_ = base;
    emit bogieChanged();
    emit wheelChanged();
    emit fieldsChanged();
}

void Bridge::setWheel(int v) {
    v = v < 0 ? 0 : (v > 5 ? 5 : v);
    if (wheel_ == v) return;
    wheel_ = v;
    bogie_ = wheel_ < 3 ? 0 : 1;
    emit wheelChanged();
    emit bogieChanged();
    emit fieldsChanged();
}

void Bridge::setLocoNumber(const QString& v) {
    const QString trimmed = v.trimmed();
    if (loco_number_ == trimmed) return;
    loco_number_ = trimmed;
    refreshLocoCheck();
    emit locoNumberChanged();
    emit sessionChanged();
}

QString Bridge::iconFontUrl() const { return res("fonts/MaterialIcons-Regular.ttf"); }
QString Bridge::thaiFontUrl() const { return res("fonts/NotoSansThaiLooped.ttf"); }
QString Bridge::latinFontUrl() const { return res("fonts/NotoSans-Regular.ttf"); }

QString Bridge::glyph(const QString& name) const {
    const QByteArray n = name.toUtf8();
    for (const Glyph& g : kGlyphs) {
        if (n == g.name) return QString(QChar(g.code));
    }
    return {};
}

int Bridge::wheelIndex() const { return wheel_; }

wheel::Side& Bridge::sideRef(bool right) {
    return sideRefAt(wheelIndex(), right);
}

wheel::Side& Bridge::sideRefAt(int wheel, bool right) {
    if (wheel < 0) wheel = 0;
    if (wheel > 5) wheel = 5;
    wheel::Wheel& w = wheels_[static_cast<size_t>(wheel)];
    return right ? w.right : w.left;
}

QVariantMap Bridge::currentFields() const {
    const wheel::Wheel& w = wheels_[static_cast<size_t>(wheel_)];
    QVariantMap m;
    auto put = [&](const QString& key, bool has, double mm) {
        m.insert(key, has ? fmt(mm, inches_) : QString());
    };
    put(QStringLiteral("rTyre"), w.right.has_tyre, w.right.tyre);
    put(QStringLiteral("lTyre"), w.left.has_tyre, w.left.tyre);
    put(QStringLiteral("rTread"), w.right.has_tread, w.right.tread);
    put(QStringLiteral("lTread"), w.left.has_tread, w.left.tread);
    put(QStringLiteral("rFlange"), w.right.has_flange, w.right.flange);
    put(QStringLiteral("lFlange"), w.left.has_flange, w.left.flange);
    put(QStringLiteral("rRoot"), w.right.has_root, w.right.root);
    put(QStringLiteral("lRoot"), w.left.has_root, w.left.root);
    return m;
}

QVariantMap Bridge::currentFieldTones() const {
    const wheel::Limits lim = currentLimits();
    const wheel::Wheel& w = wheels_[static_cast<size_t>(wheel_)];
    const wheel::SideStatus rs = wheel::eval_side(w.right, lim);
    const wheel::SideStatus ls = wheel::eval_side(w.left, lim);
    wheel::Level axle_lv = wheel::Level::Empty;
    if (w.right.has_tyre && w.left.has_tyre) {
        axle_lv = wheel::diff_level(std::abs(w.right.tyre - w.left.tyre), lim.axle_mm);
    }
    QVariantMap m;
    auto put = [&](const QString& key, wheel::Level lv) {
        m.insert(key, tone_of(lv));
    };
    // Tyre wells also reflect same-axle thickness difference (status IF).
    put(QStringLiteral("rTyre"), wheel::worse(rs.tyre, axle_lv));
    put(QStringLiteral("lTyre"), wheel::worse(ls.tyre, axle_lv));
    put(QStringLiteral("rTread"), rs.tread);
    put(QStringLiteral("lTread"), ls.tread);
    put(QStringLiteral("rFlange"), rs.flange);
    put(QStringLiteral("lFlange"), ls.flange);
    put(QStringLiteral("rRoot"), rs.root);
    put(QStringLiteral("lRoot"), ls.root);
    return m;
}

QVariantMap Bridge::fieldLimitHints() const {
    const wheel::Limits lim = currentLimits();
    const QString u = unitLabel();
    auto with_u = [&](const QString& n) { return n + QLatin1Char(' ') + u; };
    QVariantMap m;
    if (lim.tyre_shop_mm > 0.0) {
        m.insert(QStringLiteral("tyre"),
                 t(QStringLiteral("lim_tyre_shop"))
                     .arg(with_u(fmt(lim.tyre_shop_mm, inches_)),
                          with_u(fmt(lim.tyre_scrap_mm, inches_)),
                          with_u(fmt(lim.axle_mm, inches_))));
    } else {
        m.insert(QStringLiteral("tyre"),
                 t(QStringLiteral("lim_tyre"))
                     .arg(with_u(fmt(lim.tyre_scrap_mm, inches_)),
                          with_u(fmt(lim.axle_mm, inches_))));
    }
    m.insert(QStringLiteral("tread"),
             t(QStringLiteral("lim_wear"))
                 .arg(with_u(fmt(lim.tread_shop_mm, inches_)),
                      with_u(fmt(lim.tread_scrap_mm, inches_))));
    m.insert(QStringLiteral("flange"),
             t(QStringLiteral("lim_wear"))
                 .arg(with_u(fmt(lim.flange_shop_mm, inches_)),
                      with_u(fmt(lim.flange_scrap_mm, inches_))));
    m.insert(QStringLiteral("root"),
             t(QStringLiteral("lim_root"))
                 .arg(with_u(fmt(lim.root_ok_mm, inches_)),
                      with_u(fmt(lim.root_scrap_mm, inches_))));
    return m;
}

void Bridge::setField(const QString& key, const QString& text, int wheelIndex) {
    const int wi = wheelIndex < 0 ? wheel_ : wheelIndex;
    if (wi < 0 || wi > 5) return;
    const QString trimmed = text.trimmed();
    const bool right = key.startsWith(QLatin1Char('r'));
    wheel::Side& s = sideRefAt(wi, right);
    bool* has = nullptr;
    double* val = nullptr;
    if (key.endsWith(QLatin1String("Tyre"))) {
        has = &s.has_tyre;
        val = &s.tyre;
    } else if (key.endsWith(QLatin1String("Tread"))) {
        has = &s.has_tread;
        val = &s.tread;
    } else if (key.endsWith(QLatin1String("Flange"))) {
        has = &s.has_flange;
        val = &s.flange;
    } else if (key.endsWith(QLatin1String("Root"))) {
        has = &s.has_root;
        val = &s.root;
    } else {
        return;
    }
    if (trimmed.isEmpty()) {
        *has = false;
        *val = 0;
    } else {
        QString parse = trimmed;
        // Allow in-progress decimals ("45.") without dropping the previous save.
        if (parse.endsWith(QLatin1Char('.')) || parse.endsWith(QLatin1Char(',')))
            parse.chop(1);
        if (parse.isEmpty()) return;
        bool ok = false;
        const double disp = parse.toDouble(&ok);
        if (!ok) return;
        *has = true;
        *val = wheel::from_display(disp, inches_);
    }
    emit fieldsChanged();
    recompute();
}

void Bridge::clearCurrentWheel() {
    wheels_[static_cast<size_t>(wheel_)] = {};
    emit fieldsChanged();
    recompute();
}

void Bridge::clearAll() {
    wheels_ = {};
    emit fieldsChanged();
    recompute();
}

void Bridge::pushResult(const QString& title, const QString& detail, wheel::Level lv, bool valid,
                        const QString& group) {
    if (!valid) return;
    QVariantMap row;
    row.insert(QStringLiteral("title"), title);
    row.insert(QStringLiteral("detail"), detail);
    row.insert(QStringLiteral("status"), levelLabel(lv));
    row.insert(QStringLiteral("tone"), tone_of(lv));
    row.insert(QStringLiteral("group"), group);
    result_rows_.push_back(row);
}

void Bridge::recompute() {
    const wheel::Report rep = wheel::evaluate(wheels_, currentLimits());
    result_rows_.clear();
    const QString u = unitLabel();

    const QString gAxle = QStringLiteral("axle");
    const QString gBogie = QStringLiteral("bogie");
    const QString gLoco = QStringLiteral("loco");
    const QString gWear = QStringLiteral("wear");
    for (int i = 0; i < 6; ++i) {
        const auto& d = rep.axle[static_cast<size_t>(i)];
        if (!d.valid) continue;
        pushResult(t(QStringLiteral("axle_of")).arg(i + 1),
                   t(QStringLiteral("diff_val")).arg(fmt(d.value_mm, inches_), u), d.level, true, gAxle);
    }
    if (rep.bogie1.valid)
        pushResult(t(QStringLiteral("bogie")) + QStringLiteral(" 1"),
                   t(QStringLiteral("diff_val")).arg(fmt(rep.bogie1.value_mm, inches_), u), rep.bogie1.level, true, gBogie);
    if (rep.bogie2.valid)
        pushResult(t(QStringLiteral("bogie")) + QStringLiteral(" 2"),
                   t(QStringLiteral("diff_val")).arg(fmt(rep.bogie2.value_mm, inches_), u), rep.bogie2.level, true, gBogie);
    if (rep.loco.valid)
        pushResult(t(QStringLiteral("loco_diff")),
                   t(QStringLiteral("diff_val")).arg(fmt(rep.loco.value_mm, inches_), u), rep.loco.level, true, gLoco);

    auto sideHits = [&](int wi, bool right, const wheel::SideStatus& st, const wheel::Side& s) {
        const QString side = right ? t(QStringLiteral("right")) : t(QStringLiteral("left"));
        const QString wh = t(QStringLiteral("wheel")) + QStringLiteral(" %1 · %2").arg(wi + 1).arg(side);
        if (s.has_tyre && st.tyre != wheel::Level::Ok && st.tyre != wheel::Level::Empty)
            pushResult(t(QStringLiteral("tyre")) + QStringLiteral(" · ") + wh,
                       QStringLiteral("%1 %2").arg(fmt(s.tyre, inches_), u), st.tyre, true, gWear);
        if (s.has_tread && st.tread != wheel::Level::Ok && st.tread != wheel::Level::Empty)
            pushResult(t(QStringLiteral("tread")) + QStringLiteral(" · ") + wh,
                       t(QStringLiteral("wear_val")).arg(fmt(s.tread, inches_), u), st.tread, true, gWear);
        if (s.has_flange && st.flange != wheel::Level::Ok && st.flange != wheel::Level::Empty)
            pushResult(t(QStringLiteral("flange")) + QStringLiteral(" · ") + wh,
                       t(QStringLiteral("wear_val")).arg(fmt(s.flange, inches_), u), st.flange, true, gWear);
        if (s.has_root && st.root != wheel::Level::Ok && st.root != wheel::Level::Empty)
            pushResult(t(QStringLiteral("root")) + QStringLiteral(" · ") + wh,
                       t(QStringLiteral("wear_val")).arg(fmt(s.root, inches_), u), st.root, true, gWear);
    };
    for (int i = 0; i < 6; ++i) {
        sideHits(i, true, rep.right_status[static_cast<size_t>(i)], wheels_[static_cast<size_t>(i)].right);
        sideHits(i, false, rep.left_status[static_cast<size_t>(i)], wheels_[static_cast<size_t>(i)].left);
    }

    if (result_rows_.isEmpty()) {
        QVariantMap row;
        row.insert(QStringLiteral("title"), t(QStringLiteral("no_data")));
        row.insert(QStringLiteral("detail"), t(QStringLiteral("no_data_hint")));
        row.insert(QStringLiteral("status"), QStringLiteral("—"));
        row.insert(QStringLiteral("tone"), QStringLiteral("empty"));
        result_rows_.push_back(row);
        worst_label_ = QStringLiteral("—");
        worst_tone_ = QStringLiteral("empty");
    } else {
        worst_label_ = levelLabel(rep.worst);
        worst_tone_ = tone_of(rep.worst);
    }
    emit resultsChanged();
}

QVariantList Bridge::fleetOptions() const {
    QVariantList rows;
    const struct {
        const char* code;
        const char* title_key;
        const char* sub_key;
    } opts[] = {
        {"ALS", "fleet_als", "fleet_als_sub"},
        {"GEK", "fleet_gek", "fleet_gek_sub"},
        {"HID", "fleet_hid", "fleet_hid_sub"},
        {"GEA", "fleet_gea", "fleet_gea_sub"},
        {"CSR", "fleet_csr", "fleet_csr_sub"},
        {"QSY", "fleet_qsy", "fleet_qsy_sub"},
    };
    for (const auto& o : opts) {
        QVariantMap m;
        const QString code = QString::fromUtf8(o.code);
        m.insert(QStringLiteral("code"), code);
        m.insert(QStringLiteral("title"), t(QString::fromUtf8(o.title_key)));
        m.insert(QStringLiteral("sub"), t(QString::fromUtf8(o.sub_key)));
        m.insert(QStringLiteral("icon"),
                 QStringLiteral("qrc:/wheel/fleet/") + code.toLower() + QStringLiteral(".png"));
        rows.push_back(m);
    }
    return rows;
}

QVariantList Bridge::guideCards() const {
    const wheel::Limits lim = wheel::limits_for(guide_fleet_);
    const QString u = unitLabel();
    QVariantList rows;
    auto add = [&](const QString& cat, const QString& badge, const QString& title, const QString& value,
                   const QString& note, const QString& tone) {
        QVariantMap m;
        m.insert(QStringLiteral("cat"), cat);
        m.insert(QStringLiteral("badge"), badge);
        m.insert(QStringLiteral("title"), title);
        m.insert(QStringLiteral("value"), value);
        m.insert(QStringLiteral("note"), note);
        m.insert(QStringLiteral("tone"), tone);
        rows.push_back(m);
    };
    add(QStringLiteral("diff"), t(QStringLiteral("badge_diff")), t(QStringLiteral("axle_same")),
        fmt(lim.axle_mm, inches_) + QLatin1Char(' ') + u, t(QStringLiteral("guide_axle_note")), QStringLiteral("ok"));
    add(QStringLiteral("diff"), t(QStringLiteral("badge_diff")), t(QStringLiteral("bogie_same")),
        fmt(lim.bogie_mm, inches_) + QLatin1Char(' ') + u, t(QStringLiteral("guide_bogie_note")), QStringLiteral("warn"));
    add(QStringLiteral("diff"), t(QStringLiteral("badge_diff")), t(QStringLiteral("loco_diff")),
        fmt(lim.loco_mm, inches_) + QLatin1Char(' ') + u, t(QStringLiteral("guide_loco_note")), QStringLiteral("bad"));
    if (lim.tyre_shop_mm > 0.0) {
        add(QStringLiteral("scrap"), t(QStringLiteral("badge_scrap")), t(QStringLiteral("tyre_limits")),
            fmt(lim.tyre_shop_mm, inches_) + QStringLiteral(" / ") + fmt(lim.tyre_scrap_mm, inches_) + QLatin1Char(' ') + u,
            t(QStringLiteral("tyre_shop_scrap")), QStringLiteral("bad"));
    } else {
        add(QStringLiteral("scrap"), t(QStringLiteral("badge_scrap")), t(QStringLiteral("tyre_scrap")),
            fmt(lim.tyre_scrap_mm, inches_) + QLatin1Char(' ') + u, t(QStringLiteral("guide_tyre_note")), QStringLiteral("bad"));
    }
    add(QStringLiteral("wear"), t(QStringLiteral("badge_wear")), t(QStringLiteral("tread_limits")),
        fmt(lim.tread_shop_mm, inches_) + QStringLiteral(" / ") + fmt(lim.tread_scrap_mm, inches_) + QLatin1Char(' ') + u,
        t(QStringLiteral("shop_scrap")), QStringLiteral("warn"));
    add(QStringLiteral("wear"), t(QStringLiteral("badge_wear")), t(QStringLiteral("flange_limits")),
        fmt(lim.flange_shop_mm, inches_) + QStringLiteral(" / ") + fmt(lim.flange_scrap_mm, inches_) + QLatin1Char(' ') + u,
        t(QStringLiteral("shop_scrap")), QStringLiteral("warn"));
    add(QStringLiteral("wear"), t(QStringLiteral("badge_wear")), t(QStringLiteral("root_limits")),
        fmt(lim.root_ok_mm, inches_) + QStringLiteral(" / ") + fmt(lim.root_scrap_mm, inches_) + QLatin1Char(' ') + u,
        t(QStringLiteral("ok_scrap")), QStringLiteral("ok"));
    return rows;
}

QString Bridge::prefsPath() const {
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    return dir + QStringLiteral("/wheel_limits.json");
}

void Bridge::loadPrefs() {
    QString path = prefsPath();
    if (!QFile::exists(path)) {
        // Migrate from older app ids (als_wheel / srt_wheel).
        const QFileInfo fi(path);
        const QString base = fi.dir().absolutePath();
        const QStringList tryPaths = {
            QDir::cleanPath(base + QStringLiteral("/../als_wheel/als_wheel.json")),
            QDir::cleanPath(base + QStringLiteral("/../srt_wheel/srt_wheel.json")),
            QDir::cleanPath(base + QStringLiteral("/../srt_wheel/wheel_limits.json")),
            fi.dir().filePath(QStringLiteral("als_wheel.json")),
            fi.dir().filePath(QStringLiteral("srt_wheel.json")),
        };
        for (const QString& p : tryPaths) {
            if (QFile::exists(p)) {
                path = p;
                break;
            }
        }
    }
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) return;
    const auto doc = QJsonDocument::fromJson(f.readAll());
    if (!doc.isObject()) return;
    const QJsonObject o = doc.object();
    dark_ = o.value(QStringLiteral("dark")).toBool(true);
    inches_ = o.value(QStringLiteral("inches")).toBool(false);
    large_ = o.value(QStringLiteral("large")).toBool(true);
    lang_ = o.value(QStringLiteral("lang")).toString();
    if (lang_ != QLatin1String("en")) lang_ = QStringLiteral("th");
    loco_number_ = o.value(QStringLiteral("loco")).toString();
    QString fc = o.value(QStringLiteral("fleet")).toString();
    if (fc.isEmpty()) fc = QStringLiteral("ALS");
    fleet_ = wheel::fleet_from_code(fc.toUtf8().constData());
    guide_fleet_ = fleet_;
    fleet_picked_ = o.value(QStringLiteral("fleetPicked")).toBool(false);
    saved_.clear();
    const QJsonArray arr = o.value(QStringLiteral("saved")).toArray();
    for (const QJsonValue& v : arr) {
        if (v.isObject()) saved_.push_back(v.toObject().toVariantMap());
    }
}

void Bridge::savePrefs() const {
    QJsonObject o;
    o.insert(QStringLiteral("dark"), dark_);
    o.insert(QStringLiteral("inches"), inches_);
    o.insert(QStringLiteral("large"), large_);
    o.insert(QStringLiteral("lang"), lang_);
    o.insert(QStringLiteral("loco"), loco_number_);
    o.insert(QStringLiteral("fleet"), fleetCode());
    o.insert(QStringLiteral("fleetPicked"), fleet_picked_);
    QJsonArray arr;
    for (const QVariant& v : saved_) arr.push_back(QJsonObject::fromVariantMap(v.toMap()));
    o.insert(QStringLiteral("saved"), arr);
    QFile f(prefsPath());
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) return;
    f.write(QJsonDocument(o).toJson(QJsonDocument::Compact));
}

QStringList Bridge::savedLocoIds() const {
    QStringList ids;
    for (const QVariant& v : saved_) {
        const QVariantMap m = v.toMap();
        const QString id = m.value(QStringLiteral("loco")).toString();
        const QString fl = m.value(QStringLiteral("fleet")).toString();
        if (id.isEmpty()) continue;
        const QString label = fl.isEmpty() ? id : (fl + QStringLiteral(" ") + id);
        if (!ids.contains(label)) ids.push_back(label);
    }
    return ids;
}

QString Bridge::formatWhen(const QString& iso) const {
    if (iso.isEmpty()) return QStringLiteral("—");
    const QDateTime dt = QDateTime::fromString(iso, Qt::ISODate);
    if (!dt.isValid()) return iso;
    return dt.toString(QStringLiteral("yyyy-MM-dd HH:mm"));
}

void Bridge::setHistorySort(const QString& v) {
    QString n = v;
    if (n != QLatin1String("created") && n != QLatin1String("loco"))
        n = QStringLiteral("modified");
    if (history_sort_ == n) return;
    history_sort_ = n;
    emit historyChanged();
}

QVariantList Bridge::historyRows() const {
    struct Row {
        int index = 0;
        QVariantMap map;
        QString created;
        QString modified;
        QString loco;
        int locoNum = 0;
    };
    QList<Row> rows;
    rows.reserve(saved_.size());
    for (int i = 0; i < saved_.size(); ++i) {
        const QVariantMap m = saved_[i].toMap();
        Row r;
        r.index = i;
        r.map = m;
        r.loco = m.value(QStringLiteral("loco")).toString();
        const QString when = m.value(QStringLiteral("when")).toString();
        r.created = m.value(QStringLiteral("created")).toString();
        r.modified = m.value(QStringLiteral("modified")).toString();
        if (r.created.isEmpty()) r.created = when;
        if (r.modified.isEmpty()) r.modified = when;
        bool ok = false;
        r.locoNum = r.loco.toInt(&ok);
        if (!ok) r.locoNum = 0;
        rows.push_back(r);
    }

    const QString sort = history_sort_;
    std::sort(rows.begin(), rows.end(), [&](const Row& a, const Row& b) {
        if (sort == QLatin1String("loco")) {
            if (a.locoNum != b.locoNum) return a.locoNum < b.locoNum;
            return a.loco < b.loco;
        }
        if (sort == QLatin1String("created"))
            return a.created > b.created;  // newest created first
        return a.modified > b.modified;    // newest edited first
    });

    QVariantList out;
    out.reserve(rows.size());
    for (const Row& r : rows) {
        QVariantMap m;
        const QString fl = r.map.value(QStringLiteral("fleet")).toString();
        m.insert(QStringLiteral("index"), r.index);
        m.insert(QStringLiteral("loco"), r.loco);
        m.insert(QStringLiteral("fleet"), fl);
        m.insert(QStringLiteral("label"), fl.isEmpty() ? r.loco : (fl + QStringLiteral(" ") + r.loco));
        m.insert(QStringLiteral("created"), r.created);
        m.insert(QStringLiteral("modified"), r.modified);
        m.insert(QStringLiteral("createdLabel"), formatWhen(r.created));
        m.insert(QStringLiteral("modifiedLabel"), formatWhen(r.modified));
        m.insert(QStringLiteral("worst"), r.map.value(QStringLiteral("worst")).toString());
        m.insert(QStringLiteral("tone"), r.map.value(QStringLiteral("tone")).toString());
        out.push_back(m);
    }
    return out;
}

bool Bridge::saveCurrent() {
    QString id = loco_number_.trimmed();
    if (id.isEmpty()) {
        const int n = saved_.size() + 1;
        id = QStringLiteral("#%1 %2")
                 .arg(n)
                 .arg(QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd HH:mm")));
        loco_number_ = id;
        emit locoNumberChanged();
    }
    recompute();
    const QString now = QDateTime::currentDateTime().toString(Qt::ISODate);
    QVariantMap rec;
    rec.insert(QStringLiteral("loco"), id);
    rec.insert(QStringLiteral("fleet"), fleetCode());
    rec.insert(QStringLiteral("when"), now);
    rec.insert(QStringLiteral("modified"), now);
    rec.insert(QStringLiteral("worst"), worst_label_);
    rec.insert(QStringLiteral("tone"), worst_tone_);
    rec.insert(QStringLiteral("rows"), result_rows_);
    QVariantList wheels;
    for (int i = 0; i < 6; ++i) {
        const wheel::Wheel& w = wheels_[static_cast<size_t>(i)];
        QVariantMap wm;
        auto side = [](const wheel::Side& s) {
            QVariantMap m;
            m.insert(QStringLiteral("tyre"), s.has_tyre ? s.tyre : QVariant());
            m.insert(QStringLiteral("tread"), s.has_tread ? s.tread : QVariant());
            m.insert(QStringLiteral("flange"), s.has_flange ? s.flange : QVariant());
            m.insert(QStringLiteral("root"), s.has_root ? s.root : QVariant());
            return m;
        };
        wm.insert(QStringLiteral("r"), side(w.right));
        wm.insert(QStringLiteral("l"), side(w.left));
        wheels.push_back(wm);
    }
    rec.insert(QStringLiteral("wheels"), wheels);

    const QString keyFleet = fleetCode();
    for (int i = 0; i < saved_.size(); ++i) {
        const QVariantMap old = saved_[i].toMap();
        if (old.value(QStringLiteral("loco")).toString() == id
            && old.value(QStringLiteral("fleet")).toString() == keyFleet) {
            QString created = old.value(QStringLiteral("created")).toString();
            if (created.isEmpty())
                created = old.value(QStringLiteral("when")).toString();
            if (created.isEmpty()) created = now;
            rec.insert(QStringLiteral("created"), created);
            saved_[i] = rec;
            save_hint_ = t(QStringLiteral("saved")) + QStringLiteral(" - ") + keyFleet + QLatin1Char(' ') + id;
            emit savedChanged();
            emit historyChanged();
            savePrefs();
            return true;
        }
    }
    rec.insert(QStringLiteral("created"), now);
    saved_.prepend(rec);
    while (saved_.size() > 40) saved_.removeLast();
    save_hint_ = t(QStringLiteral("saved")) + QStringLiteral(" - ") + keyFleet + QLatin1Char(' ') + id;
    emit savedChanged();
    emit historyChanged();
    savePrefs();
    return true;
}

void Bridge::loadRecord(int index) {
    if (index < 0 || index >= saved_.size()) return;
    const QVariantMap rec = saved_[index].toMap();
    QString fc = rec.value(QStringLiteral("fleet")).toString();
    if (fc.isEmpty()) fc = QStringLiteral("ALS");
    fleet_ = wheel::fleet_from_code(fc.toUtf8().constData());
    guide_fleet_ = fleet_;
    fleet_picked_ = true;
    emit fleetChanged();
    emit guideChanged();
    loco_number_ = rec.value(QStringLiteral("loco")).toString();
    emit locoNumberChanged();
    emit sessionChanged();
    emit guideChanged();
    const QVariantList wheels = rec.value(QStringLiteral("wheels")).toList();
    wheels_ = {};
    auto readSide = [](const QVariantMap& m) {
        wheel::Side s;
        if (m.value(QStringLiteral("tyre")).isValid()) {
            s.has_tyre = true;
            s.tyre = m.value(QStringLiteral("tyre")).toDouble();
        }
        if (m.value(QStringLiteral("tread")).isValid()) {
            s.has_tread = true;
            s.tread = m.value(QStringLiteral("tread")).toDouble();
        }
        if (m.value(QStringLiteral("flange")).isValid()) {
            s.has_flange = true;
            s.flange = m.value(QStringLiteral("flange")).toDouble();
        }
        if (m.value(QStringLiteral("root")).isValid()) {
            s.has_root = true;
            s.root = m.value(QStringLiteral("root")).toDouble();
        }
        return s;
    };
    for (int i = 0; i < 6 && i < wheels.size(); ++i) {
        const QVariantMap wm = wheels[i].toMap();
        wheels_[static_cast<size_t>(i)].right = readSide(wm.value(QStringLiteral("r")).toMap());
        wheels_[static_cast<size_t>(i)].left = readSide(wm.value(QStringLiteral("l")).toMap());
    }
    emit fieldsChanged();
    recompute();
    page_ = QStringLiteral("result");
    emit pageChanged();
}

void Bridge::deleteRecord(int index) {
    if (index < 0 || index >= saved_.size()) return;
    saved_.removeAt(index);
    emit savedChanged();
    emit historyChanged();
    savePrefs();
}

void Bridge::selectLocoId(const QString& id) {
    // Labels look like "ALS 4501" from savedLocoIds().
    for (int i = 0; i < saved_.size(); ++i) {
        const QVariantMap m = saved_[i].toMap();
        const QString loco = m.value(QStringLiteral("loco")).toString();
        const QString fl = m.value(QStringLiteral("fleet")).toString();
        const QString label = fl.isEmpty() ? loco : (fl + QStringLiteral(" ") + loco);
        if (label == id || loco == id) {
            loadRecord(i);
            return;
        }
    }
    loco_number_ = id;
    emit locoNumberChanged();
    emit sessionChanged();
}
