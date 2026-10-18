#pragma once

#include "calc.h"

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

#include <array>
#include <vector>

class Bridge : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool dark READ dark WRITE setDark NOTIFY darkChanged)
    Q_PROPERTY(bool inches READ inches WRITE setInches NOTIFY inchesChanged)
    Q_PROPERTY(bool largeControls READ largeControls WRITE setLargeControls NOTIFY largeControlsChanged)
    Q_PROPERTY(QString lang READ lang WRITE setLang NOTIFY langChanged)
    Q_PROPERTY(QString page READ page WRITE setPage NOTIFY pageChanged)
    Q_PROPERTY(QString fleetCode READ fleetCode WRITE setFleetCode NOTIFY fleetChanged)
    Q_PROPERTY(QString fleetName READ fleetName NOTIFY fleetChanged)
    Q_PROPERTY(QString tyreLabel READ tyreLabel NOTIFY fleetChanged)
    Q_PROPERTY(QString sessionTitle READ sessionTitle NOTIFY sessionChanged)
    Q_PROPERTY(QString fleetHeadline READ fleetHeadline NOTIFY sessionChanged)
    Q_PROPERTY(QString locoRangeHint READ locoRangeHint NOTIFY fleetChanged)
    Q_PROPERTY(QString locoCheckMessage READ locoCheckMessage NOTIFY locoNumberChanged)
    Q_PROPERTY(QString locoCheckTone READ locoCheckTone NOTIFY locoNumberChanged)
    Q_PROPERTY(int bogie READ bogie WRITE setBogie NOTIFY bogieChanged)
    Q_PROPERTY(int wheel READ wheel WRITE setWheel NOTIFY wheelChanged)
    Q_PROPERTY(QString locoNumber READ locoNumber WRITE setLocoNumber NOTIFY locoNumberChanged)
    Q_PROPERTY(QString unitLabel READ unitLabel NOTIFY unitChanged)
    Q_PROPERTY(QString iconFont READ iconFont CONSTANT)
    Q_PROPERTY(QString iconFontUrl READ iconFontUrl CONSTANT)
    Q_PROPERTY(QString thaiFontUrl READ thaiFontUrl CONSTANT)
    Q_PROPERTY(QString latinFontUrl READ latinFontUrl CONSTANT)
    Q_PROPERTY(QString uiFont READ uiFont CONSTANT)
    Q_PROPERTY(QString thaiFontFamily READ thaiFontFamily CONSTANT)
    Q_PROPERTY(QString latinFontFamily READ latinFontFamily CONSTANT)
    Q_PROPERTY(bool fontReady READ fontReady CONSTANT)
    Q_PROPERTY(QVariantList resultRows READ resultRows NOTIFY resultsChanged)
    Q_PROPERTY(QVariantList guideCards READ guideCards NOTIFY guideChanged)
    Q_PROPERTY(QString guideFleetCode READ guideFleetCode WRITE setGuideFleetCode NOTIFY guideChanged)
    Q_PROPERTY(QString guideFleetName READ guideFleetName NOTIFY guideChanged)
    Q_PROPERTY(QVariantList fleetOptions READ fleetOptions NOTIFY langChanged)
    Q_PROPERTY(QVariantList savedRecords READ savedRecords NOTIFY savedChanged)
    Q_PROPERTY(QStringList savedLocoIds READ savedLocoIds NOTIFY savedChanged)
    Q_PROPERTY(QVariantList historyRows READ historyRows NOTIFY historyChanged)
    Q_PROPERTY(QString historySort READ historySort WRITE setHistorySort NOTIFY historyChanged)
    Q_PROPERTY(QString worstLabel READ worstLabel NOTIFY resultsChanged)
    Q_PROPERTY(QString worstTone READ worstTone NOTIFY resultsChanged)
    Q_PROPERTY(QString saveHint READ saveHint NOTIFY savedChanged)
    Q_PROPERTY(bool canUndo READ canUndo NOTIFY undoChanged)
    Q_PROPERTY(bool canRedo READ canRedo NOTIFY undoChanged)

public:
    explicit Bridge(QObject* parent = nullptr);

    bool dark() const { return dark_; }
    void setDark(bool v);
    bool inches() const { return inches_; }
    void setInches(bool v);
    bool largeControls() const { return large_; }
    void setLargeControls(bool v);
    QString lang() const { return lang_; }
    void setLang(const QString& v);
    QString page() const { return page_; }
    void setPage(const QString& p);
    QString fleetCode() const;
    void setFleetCode(const QString& code);
    QString fleetName() const;
    QString fleetHeadline() const;
    QString tyreLabel() const;
    QString sessionTitle() const;
    QString locoRangeHint() const;
    QString locoCheckMessage() const { return loco_check_msg_; }
    QString locoCheckTone() const { return loco_check_tone_; }
    int bogie() const { return bogie_; }
    void setBogie(int v);
    int wheel() const { return wheel_; }
    void setWheel(int v);
    QString locoNumber() const { return loco_number_; }
    void setLocoNumber(const QString& v);

    QString unitLabel() const;
    QString iconFont() const { return QStringLiteral("Material Icons"); }
    QString iconFontUrl() const;
    QString thaiFontUrl() const;
    QString latinFontUrl() const;
    QString thaiFontFamily() const { return thai_family_; }
    QString latinFontFamily() const { return latin_family_; }
    QString uiFont() const { return thai_family_; }
    bool fontReady() const { return font_ready_; }
    void applyApplicationFont() const;

    QVariantList resultRows() const { return result_rows_; }
    QVariantList guideCards() const;
    QString guideFleetCode() const;
    void setGuideFleetCode(const QString& code);
    QString guideFleetName() const;
    QVariantList fleetOptions() const;
    QVariantList savedRecords() const { return saved_; }
    QStringList savedLocoIds() const;
    QVariantList historyRows() const;
    QString historySort() const { return history_sort_; }
    void setHistorySort(const QString& v);
    QString worstLabel() const { return worst_label_; }
    QString worstTone() const { return worst_tone_; }
    QString saveHint() const { return save_hint_; }
    bool canUndo() const { return !undo_.empty(); }
    bool canRedo() const { return !redo_.empty(); }

    Q_INVOKABLE QString t(const QString& key) const;
    Q_INVOKABLE QString glyph(const QString& name) const;
    Q_INVOKABLE QVariantMap currentFields() const;
    Q_INVOKABLE QVariantMap currentFieldTones() const;
    Q_INVOKABLE QVariantMap fieldLimitHints() const;
    // wheelIndex -1 = current wheel. Pass captured wheel so blur-after-switch
    // cannot write the old digits into the newly selected axle.
    Q_INVOKABLE void setField(const QString& key, const QString& text, int wheelIndex = -1);
    Q_INVOKABLE void clearCurrentWheel();
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE void undo();
    Q_INVOKABLE void redo();
    Q_INVOKABLE void recompute();
    Q_INVOKABLE bool saveCurrent();
    Q_INVOKABLE void loadRecord(int index);
    Q_INVOKABLE void deleteRecord(int index);
    Q_INVOKABLE void selectLocoId(const QString& id);
    Q_INVOKABLE void startWizard();
    Q_INVOKABLE void goEntryNav();
    Q_INVOKABLE void confirmFleet();
    Q_INVOKABLE void confirmLoco();

signals:
    void darkChanged();
    void inchesChanged();
    void unitChanged();
    void guideChanged();
    void largeControlsChanged();
    void langChanged();
    void pageChanged();
    void fleetChanged();
    void sessionChanged();
    void bogieChanged();
    void wheelChanged();
    void locoNumberChanged();
    void resultsChanged();
    void fieldsChanged();
    void savedChanged();
    void historyChanged();
    void undoChanged();

private:
    using WheelSnap = std::array<wheel::Wheel, 6>;
    QString formatWhen(const QString& iso) const;
    int wheelIndex() const;
    wheel::Side& sideRef(bool right);
    wheel::Side& sideRefAt(int wheel, bool right);
    void pushResult(const QString& title, const QString& detail, wheel::Level lv, bool valid,
                    const QString& group = QString());
    void loadPrefs();
    void savePrefs() const;
    QString prefsPath() const;
    QString levelLabel(wheel::Level lv) const;
    wheel::Limits currentLimits() const { return wheel::limits_for(fleet_); }
    void refreshLocoCheck();
    void pushUndo();
    void closeFieldEdit();

    bool dark_ = true;  // maroon railway-on-black default
    bool inches_ = false;
    bool large_ = true;
    bool fleet_picked_ = false;
    bool field_edit_open_ = false;
    QString lang_ = QStringLiteral("th");
    QString page_ = QStringLiteral("home");
    wheel::Fleet fleet_ = wheel::Fleet::Als;
    wheel::Fleet guide_fleet_ = wheel::Fleet::Als;  // browse guide without wiping entry data
    QString loco_number_;
    QString loco_check_msg_;
    QString loco_check_tone_ = QStringLiteral("empty");
    QString thai_family_ = QStringLiteral("Noto Sans Thai Looped");
    QString latin_family_ = QStringLiteral("Noto Sans");
    bool font_ready_ = false;
    int bogie_ = 0;
    int wheel_ = 0;
    std::array<wheel::Wheel, 6> wheels_{};
    std::vector<WheelSnap> undo_;
    std::vector<WheelSnap> redo_;
    QVariantList result_rows_;
    QVariantList saved_;
    QString history_sort_ = QStringLiteral("modified");  // modified | created | loco
    QString worst_label_ = QStringLiteral("—");
    QString worst_tone_ = QStringLiteral("empty");
    QString save_hint_;
};
